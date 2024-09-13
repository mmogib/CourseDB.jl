abstract type AbstractCourse end
struct FileData
    path::String
    fields::Dict{String,String}
    data::DataFrame
end

struct Student
    id::Int
    name::String
    email::String
    courses::Union{Nothing,Vector{<:AbstractCourse}}
end

struct Course <: AbstractCourse
    name::String
    term::String
    section::String
    students::Union{Nothing,Vector{Student}}
end

export FileData, FileData, Student