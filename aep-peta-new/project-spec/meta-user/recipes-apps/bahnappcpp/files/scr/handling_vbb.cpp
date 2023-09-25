//
// Created by Daniel Guertler on 25.05.23.
//
#include "../include/handling_vbb.h"

#include <iostream>
#include <utility>
#include <sstream>
#include <ctime>
#include <chrono>
#include "rapidjson/document.h"
#include "rapidjson/error/en.h"
#include <iomanip>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <codecvt>

//#define DEBUG_ON_HOST 1

using namespace rapidjson;


#define BRAM_ADDR (0x40000000)
#define BRAM_SIZE (0x10000) // 16KB

#define CONNECTION_COUNT (20)

void init_gpio(int &valuefd);

struct codecvt_utf8_utf16_bigendian : public std::codecvt_utf8_utf16<char16_t>
{
    explicit codecvt_utf8_utf16_bigendian(std::size_t refs = 0) : std::codecvt_utf8_utf16<char16_t>(refs) {}

protected:
    virtual std::codecvt_base::result do_out(std::mbstate_t& state,
                                             const char* from, const char* from_end, const char*& from_next,
                                             char16_t* to, char16_t* to_limit, char16_t*& to_next) const {
        return std::codecvt_base::error; // Disable writing (outgoing) conversion
    }

    virtual std::codecvt_base::result do_in(std::mbstate_t& state,
                                            const char* from, const char* from_end, const char*& from_next,
                                            char16_t* to, char16_t* to_limit, char16_t*& to_next) const override
    {
        std::codecvt_base::result result = std::codecvt_utf8_utf16<char16_t>::do_in(state, from, from_end, from_next, to, to_limit, to_next);

        // Swap bytes to convert to big-endian
        for (char16_t* p = to; p < to_next; ++p)
        {
            *p = ((*p & 0xFF00) >> 8) | ((*p & 0x00FF) << 8);
        }

        return result;
    }
};


void print_buffer(void *buffer) {
    auto *sp = static_cast<std::u16string *>(buffer);
    std::u16string s = *sp;
//    std::wstring_convert<codecvt_utf8_utf16_bigendian, char16_t> converter;
    std::wstring_convert<std::codecvt_utf8<char16_t, 0x10FFFF, std::little_endian>, char16_t> converter;
    std::cout << converter.to_bytes(s) << std::endl;
    delete sp;
}

void print_buffer_bytewise(void *buffer) {
    auto *sp = static_cast<uint8_t *>(buffer);
    for (int i = 0; i < 4096; i++) {
        if(i % 80 == 0)
            std::cout << std::endl;

        std::cout << std::hex << static_cast<char>(sp[i]);
    }
    std::cout << std::endl;
}


[[maybe_unused]] Station::Station(std::string name) :
        m_name(std::move(name)) {

#ifndef DEBUG_ON_HOST
    int gpio1016valuefd;
    init_gpio(gpio1016valuefd);
#endif
    printf("TEST3\r\n");
    std::cout << "Start Bahnapp for " << m_name << std::endl;
    get_id_from_server();
    uint32_t counter = 0;
    while (true) {

        m_cons.shrink_to_fit();
        m_cons.clear();

        if(get_cons_from_server() != 0) {
            std::cout << "Error getting connections from server" << std::endl;
            continue;
        }

        std::cout << "Got " << m_cons.size() << " connections on " + m_name << std::endl;

        for (auto &c: m_cons) {
            c.print_connection();
        }

#if defined(DEBUG_ON_HOST)
//        auto * host_buffer = static_cast<uint8_t *>(calloc(1024, sizeof(uint8_t)));

        FILE *fp;
        fp=fopen("test.dat","w+");
        write_connections_to_file(fp);
        fclose(fp);
//        print_buffer_bytewise(host_buffer);
    //    print_buffer(host_buffer);
//        free(host_buffer);

#else
        off_t bram_pbase = BRAM_ADDR; // physical base address
        uintptr_t *bram_vptr;
        int fd;

        // Map the BRAM physical address into user space getting a virtual address for it
        if ((fd = open("/dev/mem", O_RDWR | O_SYNC)) != -1) {
            bram_vptr = (uintptr_t *) mmap(nullptr, BRAM_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, fd, bram_pbase);
            //write gpio pin 1016
            write(gpio1016valuefd, "1", 1);
            write_connections_to_buffer(bram_vptr);
            print_buffer_bytewise(bram_vptr);
            write(gpio1016valuefd, "0", 1);
            close(fd);
        } else {
            printf("Cannot open /dev/mem\n");
            exit(1);
        }
#endif
        counter++;
        std::cout << "Refresh Counter: " << counter << std::endl;
        sleep(10);
    }
}

void init_gpio(int &valuefd) {
    int exportfd, directionfd;

    exportfd = open("/sys/class/gpio/export", O_WRONLY);
    if (exportfd < 0) {
        printf("Cannot open GPIO to export it\n");
        exit(1);
    }
    write(exportfd, "1016", 4);
    close(exportfd);
    printf("GPIO exported successfully\n");
    directionfd = open("/sys/class/gpio/gpio1016/direction", O_RDWR);
    if (directionfd < 0) {
        printf("Cannot open GPIO direction it\n");
        exit(1);
    }
    write(directionfd, "out", 4);
    close(directionfd);
    printf("GPIO direction set as output successfully\n");
    valuefd = open("/sys/class/gpio/gpio1016/value", O_RDWR);
    if (valuefd < 0) {
        printf("Cannot open GPIO value\n");
        exit(1);
    }
}

void serializeString(const std::string &str, char *&ptr, size_t padding_length) {

    std::wstring_convert<std::codecvt_utf8_utf16<char16_t, 0x10FFFF, std::little_endian>, char16_t> conv;
    std::string paddedString = str;

    //calculate real amount of characters
    std::u16string str16_temp = conv.from_bytes(str);
    size_t strSize = str16_temp.size();

    // append sapces to string
    for (size_t i = 0; i < padding_length - strSize; i++) {
        paddedString.append(" ");
    }

    std::u16string str16 = conv.from_bytes(paddedString);
    std::memcpy(ptr, str16.c_str(), padding_length * 2);
    ptr += (padding_length * 2);
}

static size_t WriteMemoryCallback(void *contents, size_t size, size_t nmemb, void *userp) {
    size_t realsize = size * nmemb;
    auto *mem = (struct MemoryStruct *) userp;

    char *ptr = static_cast<char *>(realloc(mem->memory, mem->size + realsize + 1));
    if (!ptr) {
        /* out of memory! */
        printf("not enough memory (realloc returned NULL)\n");
        return 0;
    }

    mem->memory = ptr;
    memcpy(&(mem->memory[mem->size]), contents, realsize);
    mem->size += realsize;
    mem->memory[mem->size] = 0;

    return realsize;
}

int Station::start_curl_request(const std::string &url, struct MemoryStruct &chunk,
                                 const std::function<int()> &callback_func) {
    chunk.memory = static_cast<char *>(malloc(1));  /* will be grown as needed by the realloc above */
    chunk.size = 0;    /* no data at this point */

    m_curl_handle = curl_easy_init();
    int return_code = -1;
    if (m_curl_handle) {
        curl_easy_setopt(m_curl_handle, CURLOPT_SSL_VERIFYHOST, 0);
        curl_easy_setopt(m_curl_handle, CURLOPT_SSL_VERIFYPEER, 0);
        curl_easy_setopt(m_curl_handle, CURLOPT_URL, url.c_str());
        curl_easy_setopt(m_curl_handle, CURLOPT_WRITEFUNCTION, WriteMemoryCallback);
        curl_easy_setopt(m_curl_handle, CURLOPT_WRITEDATA, (void *) &chunk);

        CURLcode res = curl_easy_perform(m_curl_handle);


        if (res != CURLE_OK) {
            std::cerr << "curl_easy_perform() failed: " << curl_easy_strerror(res) << std::endl;
        } else {
            return_code = callback_func();
        }
        curl_easy_cleanup(m_curl_handle);
        free(chunk.memory);
    }
    return return_code;
}

std::string removeDestinationInfo(const std::string &destinationString) {
    std::string result = destinationString;
    size_t openingBracketPos = result.find('(');
    size_t closingBracketPos = result.find(')');

    if (openingBracketPos != std::string::npos && closingBracketPos != std::string::npos) {
        std::string destinationInfo = result.substr(openingBracketPos + 1, closingBracketPos - openingBracketPos - 1);
        if (destinationInfo == "Berlin") {
            result.erase(openingBracketPos - 1, closingBracketPos - openingBracketPos + 2);
//            result.erase(std::remove(result.begin(), result.end(), ' '), result.end());
        }
    }
    return result;
}


/**
    * @brief Converts a date time string from the VBB API to a time string
    * @param dateTimeString The date time string from the VBB API
    * @return The time string
*/
std::string convertDateTime(const std::string &dateTimeString) {

    std::string result;
    std::istringstream ss(dateTimeString);
    std::string date, time;
    std::getline(ss, date, 'T');
    std::getline(ss, time, '+');
    std::istringstream timeStream(time);

    int hours, minutes;
    char colon;
    timeStream >> hours >> colon >> minutes;

    std::ostringstream resultStream;
    resultStream << std::setw(2) << std::setfill('0') << hours << ':' << std::setw(2) << std::setfill('0') << minutes;
    result = resultStream.str();
    return result;
}


int Station::get_cons_from_server() {
    struct MemoryStruct chunk{};
    uint8_t results = CONNECTION_COUNT;
    std::string results_string = std::to_string(results);

    std::string url_2 = "https://v6.vbb.transport.rest/stops/" + m_id + "/departures?results=" + results_string;

    return start_curl_request(url_2, chunk, [&chunk, this]() {

        Document document;
        ParseResult parseResult = document.Parse(chunk.memory);
        if (!parseResult) {
            std::cerr << "JSON parse error: %s (%u)", GetParseError_En(parseResult.Code()), parseResult.Offset();
            return -1;
        }

        if (document.HasMember("departures") && document["departures"].IsArray() && document["departures"].Size() > 0) {


            for (Value::ConstValueIterator itr = document["departures"].Begin();
                 itr != document["departures"].End(); ++itr) {
                const Value &result = *itr;
                Connection c = Connection();

                if (result.HasMember("line") && result["line"].HasMember("product") &&
                    result["line"]["product"].IsString()) {
                    c.setType(result["line"]["product"].GetString());
                }

                if (result.HasMember("when") && result["when"].IsString()) {
                    c.setDepartureTime(convertDateTime(result["when"].GetString()));
                }

                if (result.HasMember("plannedWhen") && result["plannedWhen"].IsString()) {
                    c.setPlannedTime(convertDateTime(result["plannedWhen"].GetString()));
                }

                if (result.HasMember("delay") && result["delay"].IsInt()) {
                    c.setDelay(result["delay"].GetInt() / 60);
                }

                if (result.HasMember("platform") && result["platform"].IsString()) {
                    c.setPlatform(result["platform"].GetString());
                }

                if (result.HasMember("destination") && result["destination"].HasMember("name") &&
                    result["destination"]["name"].IsString()) {
                    c.setDestination(removeDestinationInfo(result["destination"]["name"].GetString()));
                }

                if (result.HasMember("line") && result["line"].HasMember("name") && result["line"]["name"].IsString()) {
                    c.setLine(result["line"]["name"].GetString());
                }
                m_cons.push_back(c);
            }
        }
        return 0;
    });
}

int Station::get_id_from_server() {
    std::string url = "https://v6.vbb.transport.rest/locations?poi=false&addresses=false&query=" + m_name;

    struct MemoryStruct chunk{};

    return start_curl_request(url, chunk, [this, &chunk]() {
        Document document;
        ParseResult parseResult = document.Parse(chunk.memory);
        if (!parseResult) {
            std::cerr << "JSON parse error: %s (%u)", GetParseError_En(parseResult.Code()), parseResult.Offset();
            return -1;
        }

        if (document.IsArray() && document.Size() > 0) {
            const Value &result = document[0];

            if (result.HasMember("name") && result["name"].IsString()) {
                m_name = removeDestinationInfo(result["name"].GetString());
            }

            if (result.HasMember("id") && result["id"].IsString()) {
                m_id = result["id"].GetString();
                std::cout << "Got ID " << m_id << " for station " << m_name << std::endl;
            }
        }
        return 0;

    });


}

std::string getCurrentTime() {
    auto currentTime = std::chrono::system_clock::to_time_t(std::chrono::system_clock::now());
    std::tm *localTime = std::localtime(&currentTime);

    std::string hour = std::to_string((localTime->tm_hour + 2) % 24);
    std::string minute = std::to_string(localTime->tm_min);

    if (hour.length() == 1) {
        hour = "0" + hour;
    }
    if (minute.length() == 1) {
        minute = "0" + minute;
    }
//    std::ostringstream resultStream;
//    resultStream <<  std::setw(2) << std::setfill('0') << hour << ':' << std::setw(2) << std::setfill('0') << minute;
    return hour + ":" + minute;
}

void write_null_byte(char *&ptr) {
    *ptr = '\0';
    ptr++;
    *ptr = '\0';
    ptr++;
}

void Station::write_connections_to_file(FILE * file) const {
    std::string str = m_name;
    size_t strSize = str.size();
//    size_t copySize = std::min(strSize, maxlength);

    // #include <codecvt>
    std::wstring_convert<std::codecvt_utf8_utf16<char16_t, 0x10FFFF, std::little_endian>, char16_t> conv;
//    std::wstring_convert<codecvt_utf8_utf16_bigendian, char16_t> conv;
    std::u16string str16 = conv.from_bytes(str);
    fwrite(str16.c_str(), sizeof(char16_t), strSize, file);
//    std::memcpy(ptr, str16.c_str(), copySize * 2);
//    ptr += (copySize * 2);
}

void Station::write_connections_to_buffer(void *buffer) const {

    char *ptr = static_cast<char *>(buffer);

    serializeString(m_name, ptr, 30);
    write_null_byte(ptr);

    std::string currentTime = getCurrentTime();
    serializeString(currentTime, ptr, 5);
    write_null_byte(ptr);

    serializeString("Linie", ptr, 10);
    serializeString("Abfahrt", ptr, 10);
    serializeString("Delay", ptr, 14);
    serializeString("Ziel-Bhf.", ptr, 41);
    serializeString("Gleis", ptr, 5);
    write_null_byte(ptr);

    int i = 0;
    for (auto &c: m_cons) {
        c.serialize_connection(ptr);
        write_null_byte(ptr);
        i++;
        if (i >= CONNECTION_COUNT) {
            break;
        }
    }
}


void Connection::print_connection() {
    std::cout << "Type: " << m_type << std::endl;
    std::cout << "Departure Time: " << m_departure_time << std::endl;
    std::cout << "Planned Time: " << m_planned_time << std::endl;
    std::cout << "Delay: " << m_delay << std::endl;
    std::cout << "Platform: " << m_platform << std::endl;
    std::cout << "Destination: " << m_destination << std::endl;
    std::cout << "Line: " << m_line << std::endl;
    std::cout << std::endl;
}

void Connection::serialize_connection(char *&buffer) const {


//    serializeString(m_type, buffer, 6);
    serializeString(m_line, buffer, 10);
    serializeString(m_departure_time, buffer, 10);
//    serializeString(m_planned_time, buffer, 5);

    if(m_delay > 0) {
        serializeString("+", buffer, 1);
    }else {
        serializeString(" ", buffer, 1);
    }

    serializeString(std::to_string(m_delay), buffer, 13);

    serializeString(m_destination, buffer, 42);
    serializeString(m_platform, buffer, 4);
}
