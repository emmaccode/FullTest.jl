using Pkg; Pkg.activate(".")
using Revise
using Toolips
using FullTest
toolips_process = start!(FullTest, "192.168.1.15":8000)
