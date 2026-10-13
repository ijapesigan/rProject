.LibFormat <- function(type,
                       key,
                       fields) {
  # the house layout: @Type{Key, then one "  field = {value}," per line
  types <- c(
    article = "Article",
    book = "Book",
    inbook = "InBook",
    incollection = "InCollection",
    inproceedings = "InProceedings",
    manual = "Manual",
    misc = "Misc",
    online = "Online",
    report = "Report",
    thesis = "Thesis",
    phdthesis = "PhdThesis",
    mastersthesis = "MastersThesis",
    software = "Software",
    dataset = "Dataset",
    unpublished = "Unpublished"
  )
  type <- c(types[tolower(type)], type)[1]
  fields <- fields[!is.na(fields) & nzchar(trimws(fields))]
  names(fields) <- tolower(names(fields))
  lead <- c(
    "author", "editor", "bookauthor", "booktitle",
    "date", "journaltitle", "title", "subtitle"
  )
  trail <- c("abstract", "publisher", "keywords", "library", "annotation")
  middle <- sort(setdiff(names(fields), c(lead, trail)))
  order <- c(
    intersect(lead, names(fields)),
    middle,
    intersect(trail, names(fields))
  )
  c(
    paste0("@", type, "{", key, ","),
    paste0("  ", order, " = {", fields[order], "},"),
    "}"
  )
}
