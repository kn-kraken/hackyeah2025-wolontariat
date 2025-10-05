from PyPDF2 import PdfReader, PdfWriter, PageObject

reader = PdfReader("zaswiadczenie_wolontariackie_wzor.pdf")
writer = PdfWriter()

page = reader.pages[0]

fields = reader.get_fields()
print("Dostępne pola formularza:")
print(fields)

writer.add_page(page)

writer.update_page_form_field_values(
    writer.pages[0], {"fieldname": "some filled in text"}
)

# write "output" to PyPDF2-output.pdf
with open("filled-out.pdf", "wb") as output_stream:
    writer.write(output_stream)

