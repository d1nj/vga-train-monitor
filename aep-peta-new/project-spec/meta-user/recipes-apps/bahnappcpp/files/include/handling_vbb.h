//
// Created by Daniel Guertler on 25.05.23.
//
#pragma once

#include <string>
#include <curl/curl.h>
#include <functional>
#include <utility>

void serializeString(const std::string &str, char *&ptr, size_t padding_length);

struct MemoryStruct {
    char *memory;
    size_t size;
};

class Connection;

class Station {

public:
    [[maybe_unused]] explicit Station(std::string name);

    std::string m_name;
    std::string m_id;

private:

    int start_curl_request(const std::string &url, struct MemoryStruct &chunk, const std::function<int()> &callback_func);
//    void free_curl_request(struct MemoryStruct &chunk);
    int get_id_from_server();
    int get_cons_from_server();
    void write_connections_to_buffer(void* buffer) const;
    void write_connections_to_file(FILE * file) const;
    CURL *m_curl_handle{};
    std::vector<Connection> m_cons;
};

class Connection {
public:
    Connection()= default;

    void setType(std::string type) {
        m_type = std::move(type);
    }
    void setDepartureTime(std::string departureTime) {
        m_departure_time =  std::move(departureTime);
    }

    void setPlannedTime(std::string plannedTime) {
        m_planned_time =  std::move(plannedTime);
    }

    void setDelay(uint32_t mDelay) {
        m_delay = mDelay;
    }

    void setPlatform(std::string platform) {
        m_platform = std::move(platform);
    }

    void setDestination(std::string destination) {
        m_destination = std::move(destination);
    }

    void setLine(std::string line) {
        m_line = std::move(line);
    }

    void print_connection();

    void serialize_connection(char* &buffer) const;

private:

    std::string m_type;
    std::string m_departure_time;
    std::string m_planned_time;
    int16_t m_delay{};
    std::string m_line;
    std::string m_destination;
    std::string m_platform;


//    uint8_t m_byte_couter = 0;
};




