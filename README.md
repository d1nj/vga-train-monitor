[![pipeline status](https://git.tu-berlin.de/d.guertler/aep-ss23/badges/main/pipeline.svg)](https://git.tu-berlin.de/d.guertler/aep-ss23/-/commits/main) 

# AEP-SS23

## Development Workflow

1. `git clone git@git.tu-berlin.de:d.guertler/aep-ss23.git`
1. `cd aep-ss23`

### Recreate Project
1. Clean up the workspace with `git clean -f -x -d`
    >*_⚠️ WARNING:_** This step will delete all files that are untracked by git or are git-ignored. It also deletes everything under `fpga/vivado`!
1. Open vivado and open the Tcl Console (Window -> Tcl Console)
1. `source fpga/scripts/recreate_prj.tcl`

Now you can do your work.

### Make a commit
When you are done with your work and want to commit your changes, do the following:
1. Inside the vivado Tcl Console run `source fpga/scripts/create_project_tcl.tcl`
2. Git-add and git-commit your work.
    1. Make sure no files under `fpga/vivado` are added to git
    1. Make sure no files under `fpga/bd` are added except `vga_design.bd`,`vga_design.bda` and `.gitignore`
