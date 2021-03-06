# TODO: Replace if helper in testthat gets vectorised
# https://github.com/r-lib/testthat/issues/1398
skip_if_bs4_book_deps_missing <- function() {
  check <- vapply(bs4_book_deps(), skip_if_not_installed, logical(1L), USE.NAMES = FALSE)
  invisible(check)
}

local_bs4_book <- function(name = "book",
                           title = "Awesome Cookbook",
                           author = "Yoda",
                           output_options = NULL,
                           env = parent.frame()) {

  # don't run test using this book skeleton when Pandoc is not available
  skip_if_not_pandoc()

  path <- withr::local_tempdir(.local_envir = env)

  book_skeleton(
    name = name,
    title = title,
    author = author,
    path = path
  )

  suppressMessages(
    render_book(
      path,
      output_format = "bookdown::bs4_book",
      output_options = output_options,
      quiet = TRUE
    )
  )

  return(path)
}
