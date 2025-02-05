# LaTeX-templates: Official letters

A official LaTeX letter template with support of KOMA-script templates.

## Usage

1. Update the value within `*.config.example.tex` (rename the file if you like...)
2. Provide a signature-image or logos as you like
3. Comment in the following lines in the `opts/signature.lco` file (or choose your custom one)

   ```tex
   %% !!! CHANGE THE NAME OF THE INPUT FILE !!!
   %% \input{letter.config.tex}
   \input{letter.config.example.tex}
   %% !!! ================================= !!!
   ```

4. (Optional) Rename the `scrlltr2_official.example.tex` to any file name you would like to have. The name you choose will be the name of the generated `pdf` file.
5. Run `pdflatex <my-letter.tex>`
