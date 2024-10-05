using CourseDB
using Documenter

DocMeta.setdocmeta!(CourseDB, :DocTestSetup, :(using CourseDB); recursive=true)

makedocs(;
    modules=[CourseDB],
    authors="Mohammed Alshahrani <mmogib@gmail.com> and contributors",
    sitename="CourseDB.jl",
    format=Documenter.HTML(;
        canonical="https://mmogib.github.io/CourseDB.jl",
        edit_link="master",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/mmogib/CourseDB.jl",
    devbranch="master",
)
