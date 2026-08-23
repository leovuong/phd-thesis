# PhD Thesis Project Context

This file is the standing context for the KU Leuven PhD thesis project. It records the
project goal, requirements, source material, current status, and working conventions so
that these do not need to be repeated in every conversation.

## Main goal

Create a complete PhD thesis manuscript in Quarto that can be rendered reproducibly to
PDF and that conforms to the KU Leuven Doctoral School of Biomedical Sciences,
Pharmaceutical Sciences (FFW) requirements. The thesis should be suitable for review by
the examining committee and later adaptable for the final printed thesis booklet.

The working language is expected to be English unless a later decision is made to write
the thesis in Dutch. British or American English must be chosen consistently.

## Intended thesis format

The current intended format is a compilation of research articles:

- General introduction, limited to 30 pages.
- Objectives of the research.
- At least two chapters written as research articles.
- At least one article chapter must have been published or accepted in an international
  peer-reviewed journal and must not be a review article.
- Unpublished study parts included in the thesis must be written in article form.
- Concluding discussion of at least 5 pages.
- Scientific abstract or summary of the research.
- References for the introduction and concluding discussion, limited to no more than
  100 references under the current FFW article-compilation guidance.

The thesis must also contain:

- The mandatory KU Leuven first page format.
- A short professional-career description including a list of published articles.
- Acknowledgements, personal contribution statements, and conflict-of-interest
  statements at the end of the thesis.
- A statement about the use of generative AI, including a description of its use when
  applicable and confirmation that the author reviewed the content and takes full
  responsibility for it.
- A Dutch popularized summary written for a broad audience, delivered as a ready-to-use
  one-page document. This is mandatory for submissions from 1 January 2026.

The review manuscript must be rendered in A4 reading format. The final thesis booklet
has a default size of 160 x 240 mm, which should be considered when choosing typography,
spacing, figures, and page layout. The manuscript length is normally limited to 150
pages; this may exceptionally be exceeded for a compilation of several accepted
articles. If the articles have not been submitted, the 150-page limit applies.

## Layout and presentation targets

The following local formatting notes are the working presentation target unless they
conflict with an explicit KU Leuven or journal requirement:

- Main text: Arial, 10 pt, justified.
- Line spacing: 1.5.
- Paragraph spacing: 12 pt before and 0 pt after.
- Margins: 3 cm outside and 4 cm inside for the printed/booklet layout.
- Figure text: approximately 8 pt.
- Figures should be legible in print and should avoid relying on shading or transparency.
- Prefer clear colours and black-and-white-friendly design where practical.
- Page numbering should be checked carefully; the preferred convention is centred
  numbers or even pages on the left and odd pages on the right.
- The introduction should begin at page 1 where feasible.
- Figure captions must explain abbreviations and make figures understandable on their
  own. Figure references and numbering should be generated and updated automatically.
- Abbreviation lists should use singular forms and place special symbols at the end.
- Use one spelling convention consistently; terms such as *et al.*, *a priori*, and
  *a posteriori* should be italicised where appropriate.

These layout notes are practical project conventions, not a claim that KU Leuven
mandates these exact font and spacing settings. The current KU Leuven manual states that
there are no fixed font-size or line-spacing requirements.

## Research chapters and current status

Two research papers are available and are expected to form the core article chapters:

### Fluconazole

Location: `fluconazole/`

This paper has already been partly converted to Quarto. The remaining work is expected
to be checking and completing the conversion, including text, references, figures,
tables, supplementary material, rendering, and consistency with the thesis-wide style.
The folder contains manuscript materials, artwork, references, submission files,
feedback, and an Elsevier/Quarto manuscript tutorial.

### MI tutorial

Location: `mi-tutorial/`

This paper has not yet been converted to Quarto. The work will include identifying the
source manuscript and analysis outputs, organising figures/tables/references, converting
the text and supplementary code into Quarto, and validating the rendered result.

## Reference implementations and materials

- `pragnanz_sourcecode/` is the main local example of a KU Leuven colleague's thesis
  built with Quarto. Reuse its useful structural and rendering patterns where they fit,
  but do not assume its content, styling, or thesis structure is automatically correct
  for this project.
- `quarto-phd-thesis/` is a thesis template/reference project and may contain useful
  front matter, chapter organisation, and PDF configuration patterns.
- `upf-template/` is another Quarto thesis template/reference.
- `fluconazole/manuscript-tutorial/` contains a Quarto/Elsevier manuscript setup that
  may be useful for converting the fluconazole paper.
- The attached Word documents and PDFs provide examples and administrative guidance,
  including the mandatory first thesis page, thesis booklet/cover guidance, e-portfolio,
  manuscript submission, Turnitin, and public-defence procedures.
- `references/formatting_thesis_manuscript.txt` contains local formatting and final
  checking notes.
- The authoritative online requirements are in the KU Leuven Practical Manual PhD -
  Pharmaceutical Sciences, especially section 17, Thesis Manuscript FFW:
  https://gbiomed.kuleuven.be/english/phd/PhD_Researchers/practical_manual_phdffw.html#17.Thesis_Manuscript_FFW

## Submission and administrative constraints to keep visible

- The doctoral training e-portfolio must be fully approved before the manuscript is
  sent to the examining committee.
- Submit the thesis manuscript to the examining committee and submit the supervisor's
  approval letter through KU Loket; do not upload the manuscript itself to that KU Loket
  milestone unless the current instructions explicitly change.
- Submit the full Turnitin similarity report to the Doctoral School. The thesis can only
  be uploaded to the Turnitin assignment once, so the final version must be checked
  before uploading.
- Plan for submission at least 10 weeks before the provisional public-defence date, and
  allow more time for review or holiday periods. The final doctoral plan must have been
  approved at least 6 months before thesis submission.
- After permission to defend (imprimatur), archive the thesis in Lirias and prepare the
  final printed copies and defence arrangements.

## Working principles for this project

- Keep the thesis reproducible: source text, figures, tables, references, and rendered
  outputs should have clear ownership and predictable paths.
- Prefer Quarto, Pandoc, LaTeX, and existing repository patterns over manual Word-only
  workarounds.
- Preserve the scientific content and journal-specific requirements of each paper while
  applying a coherent thesis-wide presentation layer.
- Validate each meaningful change by rendering the smallest relevant document first,
  then checking PDF output, references, figures, page numbering, and warnings.
- Keep administrative requirements and content requirements separate from optional design
  preferences, and flag conflicts for a deliberate decision.

## Decisions still to make

- Final thesis title and subtitle.
- English versus Dutch thesis language; English is the current working assumption.
- Exact chapter order and whether additional unpublished work will be included.
- Which paper is published or accepted and which paper satisfies the publication
  requirement.
- Author contribution statements for each article, including any shared-author overlap.
- Final thesis template and PDF engine, informed by `pragnanz_sourcecode/` and the local
  thesis templates.
- Final print layout and whether the 3 cm outside / 4 cm inside margin convention should
  apply only to the booklet or also to the A4 review manuscript.
- Content of the Dutch popularized one-page summary and the GenAI statement.

## Immediate work sequence

1. Inspect the existing Quarto structure and render configuration in
   `pragnanz_sourcecode/` and the thesis template projects.
2. Finish and render the fluconazole Quarto manuscript.
3. Convert the MI tutorial into a reproducible Quarto manuscript and render it.
4. Establish the shared thesis front matter, metadata, bibliography strategy, styles,
   page numbering, and mandatory sections.
5. Assemble the article chapters with the introduction, objectives, discussion, career
   description, contribution statements, acknowledgements, conflicts, GenAI statement,
   scientific abstract, and Dutch popularized summary.
6. Run a final compliance and print-readiness checklist, including Turnitin preparation.

## Source note

This context was created on 23 August 2026 from the project files and the KU Leuven
Practical Manual page accessed on that date. Online requirements can change; before final
submission, re-check the live manual and confirm any ambiguous requirement with the
Doctoral School or supervisor.