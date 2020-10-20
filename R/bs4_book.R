#' Bootstrap4 output format
#'
#' @inheritParams html_chapters
#' @param fig_caption,number_sections,self_contained,lib_dir,pandoc_args ...
#'   Arguments to be passed to \code{rmarkdown::\link{html_document}()}
#'   (\code{...} not including \code{toc}, and \code{theme}).
#' @param config A list of configuration options for the gitbook style, such as
#'   the font/theme settings.
#' @export
bs4_book <- function(
                     number_sections = TRUE,
                     lib_dir = "libs",
                     pandoc_args = NULL,
                     extra_dependencies = NULL,
                     ...,
                     split_by = c("chapter", "chapter+number", "section", "section+number", "rmd", "none"),
                     split_bib = TRUE
                     ) {
  split_by <- match.arg(split_by)

  config <- rmarkdown::html_document(
    toc = FALSE,
    self_contained = FALSE,
    theme = NULL,
    template = bookdown_file("templates", "bs4_book.html"),
    pandoc_args = pandoc_args2(pandoc_args),
    lib_dir = lib_dir,
    extra_dependencies = c(bs4_book_dependency(), extra_dependencies),
    ...
  )

  post <- config$post_processor # in case a post processor have been defined
  config$post_processor <- function(metadata, input, output, clean, verbose) {
    if (is.function(post)) {
      output <- post(metadata, input, output, clean, verbose)
    }

    move_files_html(output, lib_dir)
    output2 <- split_chapters(
      output = output,
      build = bs4_book_page,
      number_sections = number_sections,
      split_by = split_by,
      split_bib = split_bib
    )
    if (file.exists(output) && !same_path(output, output2)) {
      file.remove(output)
    }
    move_files_html(output2, lib_dir)
    output2
  }

  # config <- common_format_config(config, "html")
  config
}

bs4_book_page = function(head,
                         toc,
                         chapter,
                         link_prev,
                         link_next,
                         rmd_cur,
                         html_cur,
                         foot) {
  paste(c(head, toc, chapter, foot), collapse = '\n')
}

bs4_book_dependency <- function() {
  assets <- bookdown_file("resources", "bs4_book")

  list(htmltools::htmlDependency(
    name = "bs4_book",
    version = "1.0.0",
    src = assets,
    stylesheet = c("bootstrap-toc.css", "bs4_book.css"),
    script = "bootstrap-toc.js"
  ))
}