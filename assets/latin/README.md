# Assets: Latin

Assets contain information that is going to be taken as input to build the initial graph of the AI,
as well as tests verifying it behaves as expected.

The assets are organized as follows starting from this folder:
 - `meta.json`: Defines the order in which the "books" will be fed to the AI, potentially their respective "weights".
 - ...book_name_dirs
    - `[chapter_num].txt`: The input text
    - `[chatper_num]_rules.xml`: Additional rules that can't be derived from the text alone (yet) and translate to structs.
    - `[chapter_num]_qna.json`: Contains questions and answers to see if the AI answers correctly.
