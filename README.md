# CourseDB.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://mmogib.github.io/CourseDB.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://mmogib.github.io/CourseDB.jl/dev/)
[![Build Status](https://github.com/mmogib/CourseDB.jl/actions/workflows/CI.yml/badge.svg?branch=master)](https://github.com/mmogib/CourseDB.jl/actions/workflows/CI.yml?query=branch%3Amaster)
[![Build Status](https://ci.appveyor.com/api/projects/status/github/mmogib/CourseDB.jl?svg=true)](https://ci.appveyor.com/project/mmogib/CourseDB-jl?branch=master)




__CourseDB.jl__ is a Julia package designed to manage and manipulate course and student data at KFUPM (King Fahd University of Petroleum and Minerals). This package provides functionality to create and manage courses, students, grades, and related data, with easy file read/write operations for CSV and XLSX formats.

## Features

- **Course Management**: Create, edit, and retrieve courses based on term, code, and section.
- **Student Management**: Add students to courses from external files, retrieve student details, and store them in various formats.
- **Grades Management**: Add and retrieve student grades, manage assignments, and export grades.
- **File Operations**: Read from and write to CSV or XLSX files, making it easier to store or load course data.
- **Data Structuring**: Structured representation of courses, students, and grades using Julia structs for easy data manipulation.

## Installation

You can install the package from the Julia REPL. Press `]` to enter the package manager, and then run:

```julia
pkg> add https://github.com/mmogib/CourseDB.jl
```

## Usage

### Creating a Course

You can create a course by providing a term, course code, name, and section:

```julia
using CourseDB

course = createCourse(241, "MATH371", "Numerical Computing", 1)
```

### Adding Students to a Course

Students can be added to a course from an external CSV or XLSX file:

```julia
addStudents(course, "students.csv")
```

The file should contain columns for `id`, `name`, and `email`. These fields can be customized.

### Managing Grades

You can add grades for a course from an external file:

```julia
addGrades(course, "grades.xlsx")
```

This will read the student grades from the file and link them to the corresponding students in the course.

### Retrieving Course Data

Retrieve a list of all courses or a specific term's courses:

```julia
all_courses = courses()
term_courses = courses(241)
```

You can also retrieve grades for a specific course:

```julia
grades = getGrades(course)
```

### File Operations

CourseDB.jl can write data such as students or grades back to files:

```julia
writedata("output.xlsx", students)
```

This supports both CSV and XLSX formats.

## Structs

The package uses the following main data structures:

- `Course`: Represents a course with fields such as `id`, `term`, `code`, `name`, and `section`.
- `Student`: Represents a student with `id`, `name`, and `email`.
- `Grade`: Represents a grade with fields like `student_id`, `course_id`, `name`, `value`, and `max_value`.
- `FileData`: Stores file information including `path`, `fields`, and `data` (as a `DataFrame`).
- `Result`: Represents the outcome of data operations, including the data and a message.

## Examples

Here's a simple workflow for managing a course and its students:

```julia
using CourseDB

# Create a new course
course = createCourse(241, "MATH371", "Numerical Computing", 1)

# Add students from a file
addStudents(course, "students.csv")

# Add grades for students
addGrades(course, "grades.csv")

# Save the updated data back to a file
writedata("updated_students.xlsx", course.students)
```

## Contributing

Contributions are welcome! Feel free to open issues or submit pull requests on the [GitHub repository](https://github.com/mmogib/CourseDB.jl).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

