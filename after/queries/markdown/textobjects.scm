; extends

; Map section nodes to @section for custom text object
(section) @section.outer
(section
  (atx_heading) @_heading
  (_) @section.inner)

; Add headings as @block so ab/ib treats them like paragraphs/code blocks
(atx_heading) @block.outer
(atx_heading
  heading_content: (_) @block.inner)

(setext_heading) @block.outer
(setext_heading
  heading_content: (_) @block.inner)
