
context("Lockfile")

test_that("lockfiles can be read from file", {

  text <- '
[Section1]
# This is a comment.
Key1=Value1
Key2=Value2

[Section2]
Key1=Value1

Key2=Value2

[Nested/Section]
Key=Value
'

  file <- tempfile()
  writeLines(text, con = file)
  output <- renv_lockfile_read(file)
  expected <- list(

    Section1 = list(
      Key1 = "Value1",
      Key2 = "Value2"
    ),

    Section2 = list(
      Key1 = "Value1",
      Key2 = "Value2"
    ),

    Nested = list(
      Section = list(
        Key = "Value"
      )
    )

  )
  expect_identical(output, expected)

})

test_that("lockfiles can be diffed", {

  lhs <- list(A = 1, B = 2, C = "a", D = list(E = 1, F = 2))
  rhs <- list(A = 1, B = 3, C = "b", D = list(E = 1, F = 3))

  diff <- renv_lockfile_diff(lhs, rhs)
  expected <- list(
    B = list(before = 2, after = 3),
    C = list(before = "a", after = "b"),
    D = list(
      F = list(before = 2, after = 3)
    )
  )

  expect_identical(diff, expected)

})

test_that("named characters are serialized as expected", {

  text <- '
[Section]
Entry=
\tKey1=Value1
\tKey2=Value2
'

  data <- list(Section = list(Entry = c(Key1 = "Value1", Key2 = "Value2")))
  file <- tempfile()
  renv_lockfile_write(data, file)
  expect_equal(trimws(text), trimws(read(file)))

})
