#!/usr/bin/env cwl-runner
cwlVersion: cwl:draft-4.dev3

class: Workflow
inputs:
  render:
    type:
      type: array
      items:
        type: record
        fields:
          source: File
          renderlist: string[]
          redirect: string[]
          target: string
          brandlink: string
          brandimg: string
  schemas:
    type:
      type: array
      items:
        type: record
        fields:
          schema_in: File
          context_target: string
          rdfs_target: string
  brandimg: File
  empty:
    type: string
    default: ""

outputs:
  doc_out:
    type: File
    outputSource: merge/dir
  report:
    type: File
    outputSource: report/out
  context:
    type: File[]
    outputSource: context/out
  rdfs:
    type: File[]
    outputSource: rdfs/out

requirements:
  - class: ScatterFeatureRequirement
  - class: StepInputExpressionRequirement
  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: commonworkflowlanguage/cwltool_module

steps:
  rdfs:
    scatter: schemas
    in:
      schemas: schemas
      schema: { valueFrom: $(inputs.schemas.schema_in) }
      target: { valueFrom: $(inputs.schemas.rdfs_target) }
    out: [out]
    run: makerdfs.cwl

  context:
    scatter: schemas
    in:
      schemas: schemas
      schema: { valueFrom: $(inputs.schemas.schema_in) }
      target: { valueFrom: $(inputs.schemas.rdfs_target) }
    out: [out]
    run: makecontext.cwl

  docs:
    scatter: render
    in:
      render: render
      source: { valueFrom: $(inputs.render.source) }
      target: { valueFrom: $(inputs.render.target) }
      renderlist: { valueFrom: $(inputs.render.renderlist) }
      redirect: { valueFrom: $(inputs.render.redirect) }
      brandlink: { valueFrom: $(inputs.render.brandlink) }
      brand: { valueFrom: $(inputs.render.brandimg) }
      primtype: { valueFrom: $(inputs.render.primtype) }
    out: [out, targetdir]
    run:  makedoc.cwl

  merge:
    in:
      primary:
        source: docs/out
        valueFrom: $(self[0])
      secondary:
        source: [docs/out, brandimg]
        linkMerge: merge_flattened
        valueFrom: $(self.slice(1))
      dirs:
        source: [docs/targetdir, empty]
        linkMerge: merge_flattened
        valueFrom: $(self.slice(1))
    out: [dir]
    run: mergesecondary.cwl

  report:
    in:
      inp: merge/dir
      target: { default: "linkchecker-report.txt"}
    out: [out]
    run: linkchecker.cwl
