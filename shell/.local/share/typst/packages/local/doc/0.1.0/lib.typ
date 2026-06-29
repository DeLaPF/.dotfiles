// doc — a clean, tinkerable general-purpose document template.
//
// Usage in any .typ file (anywhere on disk):
//   #import "@local/doc:0.1.0": doc
//   #show: doc.with(title: "My Title", author: "De La", date: "2026-06-28")
//
//   = A heading
//   Body prose goes here — the template handles layout/typography.
//
// Everything below is meant to be tinkered with. The font line uses a fallback
// list: a clean sans on macOS (Helvetica Neue / Arial), falling back to the
// typst-bundled Libertinus Serif elsewhere so it always renders.

#let doc(
  title: none,
  author: none,
  date: none,
  body,
) = {
  set page(paper: "us-letter", margin: (x: 1.1in, y: 1in), numbering: "1")
  set text(font: ("Helvetica Neue", "Arial", "Libertinus Serif"), size: 11pt)
  set par(justify: true, leading: 0.78em, spacing: 1.15em)

  // Headings: same family, bold, with breathing room.
  show heading: set text(weight: "bold")
  show heading.where(level: 1): it => block(above: 1.6em, below: 0.7em, text(size: 15pt, it))
  show heading.where(level: 2): it => block(above: 1.2em, below: 0.5em, text(size: 12.5pt, it))

  // Subtle, colored links.
  show link: set text(fill: rgb("#2151a1"))

  // Title block: large title, muted byline, thin rule.
  if title != none {
    text(size: 22pt, weight: "bold", title)
    let meta = ()
    if author != none { meta.push(author) }
    if date != none { meta.push(date) }
    if meta.len() > 0 {
      linebreak()
      v(0.2em)
      text(size: 10pt, fill: luma(120), meta.join("  ·  "))
    }
    v(0.5em)
    line(length: 100%, stroke: 0.5pt + luma(210))
    v(1.3em)
  }

  body
}
