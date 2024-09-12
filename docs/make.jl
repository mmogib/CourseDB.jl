using KFUPMCourseDB
using Documenter

DocMeta.setdocmeta!(KFUPMCourseDB, :DocTestSetup, :(using KFUPMCourseDB); recursive=true)

makedocs(;
    modules=[KFUPMCourseDB],
    authors="Mohammed Alshahrani <mmogib@gmail.com> and contributors",
    sitename="KFUPMCourseDB.jl",
    format=Documenter.HTML(;
        canonical="https://mmogib.github.io/KFUPMCourseDB.jl",
        edit_link="master",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/mmogib/KFUPMCourseDB.jl",
    devbranch="master",
)
