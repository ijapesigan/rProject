.LibFormat <- function(type,
                       key,
                       fields) {
  # the house layout: @Type{Key, then one "  field = {value}," per line
  types <- c(
    article = "Article",
    book = "Book",
    collection = "Collection",
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
  # a type not in the list keeps its spelling
  house <- types[tolower(x = type)]
  type <- if (is.na(x = house)) {
    type
  } else {
    unname(obj = house)
  }
  fields <- fields[!is.na(x = fields) & nzchar(x = trimws(x = fields))]
  names(x = fields) <- tolower(x = names(x = fields))
  lead <- c(
    "author", "editor", "bookauthor", "booktitle",
    "date", "journaltitle", "title", "subtitle"
  )
  trail <- c("abstract", "publisher", "keywords", "library", "annotation")
  middle <- sort(x = setdiff(x = names(x = fields), y = c(lead, trail)))
  order <- c(
    intersect(x = lead, y = names(x = fields)),
    middle,
    intersect(x = trail, y = names(x = fields))
  )
  c(
    paste0("@", type, "{", key, ","),
    paste0("  ", order, " = {", fields[order], "},"),
    "}"
  )
}
