// slides — minimal 16:9 slide deck (PDF). No external dependencies.
//
//   #import "@local/slides:0.1.0": slides, title-slide, slide
//   #show: slides
//   #title-slide(title: "My Talk", author: "De La", date: "June 2026")
//   #slide(title: "First topic")[
//     - point one
//     - point two
//   ]
//   #slide(title: "Second topic")[ ... ]

#let slides(body) = {
  set page(paper: "presentation-16-9", margin: 2.5em, fill: white)
  set text(font: ("Helvetica Neue", "Arial", "Libertinus Serif"), size: 22pt)
  set par(leading: 0.7em)
  body
}

// A centered title slide on a dark background (one page).
#let title-slide(title: none, subtitle: none, author: none, date: none) = {
  let meta = ()
  if author != none { meta.push(author) }
  if date != none { meta.push(date) }
  page(fill: rgb("#1c2330"), margin: 2.5em)[
    #set text(fill: white)
    #v(1fr)
    #align(center)[
      #text(size: 44pt, weight: "bold", title)
      #if subtitle != none { linebreak(); v(0.3em); text(size: 24pt, fill: luma(200), subtitle) }
      #if meta.len() > 0 { v(1em); text(size: 18pt, fill: luma(220), meta.join("  ·  ")) }
    ]
    #v(1fr)
  ]
}

// A content slide with an optional title (one page each).
#let slide(title: none, body) = {
  pagebreak(weak: true)
  if title != none {
    text(size: 30pt, weight: "bold", title)
    v(0.3em)
    line(length: 100%, stroke: 1pt + luma(200))
    v(0.6em)
  }
  body
}
