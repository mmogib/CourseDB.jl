function readdata(filepath::String, args...; kwargs...)::FileData
    @assert isfile(filepath) "The file $filepath does not exist."
    kind = basename(filepath) |> d -> split(d, ".") |> d -> d[end]
    @assert kind in ["csv", "txt", "xlsx"] "The file extension $kind is not supported."
    data = if kind in ["csv", "txt"]
        CSV.File(filepath; kwargs...) |> DataFrame
    else
        XLSX.readtable(filepath, args...; kwargs...) |> DataFrame
    end

    fields = map(names(data)) do x
        val = typeof(x) <: Real ? "number" : "string"
        x => val
    end |> Dict

    FileData(filepath, fields, data)
end

# function readdata(::Type{Student}, args...; table_fields::Union{Nothing,Dict{String,String}}, kwargs...)::Union{Nothing,FileData}
#     df = readdata(args...; kwargs..., table="students")
#     isnothing(df) && return df
#     data = df.data
#     students = if isnothing(table_fields)
#         select(data,)
#     db_students = load_students()


# end

Course(name::String, term::String, section::String, students::DataFrame, mapping::Dict{Symbol,String}=Dict(:id => "id", :name => "name", email => "email")) = begin
    students = dropmissing(students)
    course_df = add_course(name, term, section)
    course = Course(course_df[!, :course][1], course_df[!, :term][1], course_df[!, :section][1], nothing)
    stds = map(x -> Student(isa(x[mapping[:id]], Int) ? x[mapping[:id]] : parse(Int, x[mapping[:id]]), x[mapping[:name]], x[mapping[:email]], [course]), eachrow(students))
    students_df = DataFrame(id=map(x -> x.id, stds), name=map(x -> x.name, stds), email=map(x -> x.email, stds), course_id=map(x -> "$term$course$section", stds))

    save_students(students_df, name, term, section)
    Course(name, term, section, stds)
end
Course(id::String) = begin
    course_df = get_course(id)
    students = map(x -> Student(x[:id], x[:name], x[:email], nothing), eachrow(course_df))
    Course(course_df[!, :course][1], course_df[!, :term][1], course_df[!, :section][1], students)
end
Student(id::Int) = begin
    student_df = get_student(id)
    @assert nrow(student_df) > 0 "No student with id. Please check the student id"
    courses = map(x -> Course(x[:course], x[:term], x[:section], []), eachrow(student_df))
    Student(id, student_df[!, :name][1], student_df[!, :email][1], courses)
end

export readdata, Course, Student