// letter — a simple business letter.
//
//   #import "@local/letter:0.1.0": letter
//   #show: letter.with(
//     sender: [De La Petrillo-Foster \ 123 Example St \ City, ST 00000],
//     recipient: [Jane Doe \ Acme Corp \ 456 Market St \ City, ST 00000],
//     subject: "Partnership proposal",
//     signature: "De La Petrillo-Foster",
//   )
//
//   Body paragraphs go here...
//
// `date` defaults to today; pass a string to override. Everything is tinkerable.

#let letter(
  sender: none,        // content, e.g. [Name \ Street \ City]
  recipient: none,     // content
  date: auto,          // auto = today; or a string
  subject: none,       // string
  salutation: [Dear Sir or Madam,],
  closing: [Sincerely,],
  signature: none,     // typed name under the closing
  body,
) = {
  set page(paper: "us-letter", margin: 1in)
  set text(font: ("Helvetica Neue", "Arial", "Libertinus Serif"), size: 11pt)
  // Ragged-right (no justify) reads more naturally in a letter; one consistent
  // gap between blocks and paragraphs gives an even rhythm.
  set par(leading: 0.65em, spacing: 1.1em)
  let gap = v(1.1em)

  let shown-date = if date == auto {
    datetime.today().display("[month repr:long] [day], [year]")
  } else { date }

  if sender != none { sender; gap }
  if shown-date != none { shown-date; gap }
  if recipient != none { recipient; gap }
  if subject != none { strong[Re: #subject]; gap }
  if salutation != none { salutation; parbreak() }

  body

  gap
  if closing != none { closing }
  v(3em)   // room for a signature
  if signature != none { signature }
}
