import json
import os
import time

import gradio as gr
from llm_prompt import LLM_GPT4O_PROMPT
from openai import OpenAI
from paddleocr import PaddleOCR


def make_interpret_invoice_image(paddle_ocr, openai_client):
    def interpret_invoice_image(file_path):
        time_start = time.time()
        result = paddle_ocr.ocr(file_path, cls=True)[0]
        extracted_text = ", ".join([line[-1][0] for line in result])
        time_ocr = time.time()

        response = openai_client.chat.completions.create(
            model="gpt-4o",
            messages=[
                {
                    "role": "system",
                    "content": [
                        {
                            "type": "text",
                            "text": LLM_GPT4O_PROMPT,
                        }
                    ],
                },
                {"role": "user", "content": [{"type": "text", "text": extracted_text}]},
            ],
            temperature=1,
            max_tokens=1665,  # Calculate this to be exact-ish!
            top_p=1,
            frequency_penalty=0,
            presence_penalty=0,
        )
        time_openai = time.time()

        structured_data = response.choices[0].message.content.strip("```json\n")
        # json.loads(structured_data)
        pretty_json = json.dumps(json.loads(structured_data), indent=4, ensure_ascii=False)
        time_end = time.time()

        return f"""{pretty_json}\n
            Total time: {time_end-time_start:.2f} seconds
            OCR time: {time_ocr-time_start:.2f} seconds
            LLM time: {time_openai-time_ocr:.2f} seconds
            Post processing time: {time_end-time_openai:.2f} seconds
        """

    return interpret_invoice_image


def main():
    paddle_ocr = PaddleOCR(use_angle_cls=True, lang="sv")

    # We dont need to pass this env var here, but lets keep it explicit!
    openai_client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

    demo = gr.Interface(
        fn=make_interpret_invoice_image(paddle_ocr, openai_client),
        inputs=gr.Image(type="filepath"),
        outputs=gr.Textbox(
            lines=50,
            show_label=True,
            show_copy_button=True,
            interactive=True,
        ),
    )

    demo.launch()


if __name__ == "__main__":
    main()
