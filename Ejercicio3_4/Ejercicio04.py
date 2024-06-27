import string
from collections import Counter
import os

def find_txt_file(file_name):
    common_locations = [
        os.path.join(os.path.expanduser('~'), 'Desktop'),  
        os.path.join(os.path.expanduser('~'), 'Documents'), 
        os.path.join(os.path.expanduser('~'), 'Pictures')
    ]
    
    for location in common_locations:
        for root, _, files in os.walk(location):
            for file in files:
                if file.lower() == file_name.lower() and file_name.lower().endswith('.txt'):
                    return os.path.join(root, file)
    
    return None

def process_file(input_file):
    try:
        txt_file_path = find_txt_file(input_file)
        
        if not txt_file_path:
            raise FileNotFoundError(f'El archivo "{input_file}" no fue encontrado en las ubicaciones comunes.')
        
        word_freq = Counter()
        
        with open(txt_file_path, 'r', encoding='utf-8') as file:
            for line in file:
                line = line.lower() 
                line = line.translate(str.maketrans('', '', string.punctuation))
                words = line.split()
                word_freq.update(words)
        
        output_file = 'resultado.txt'
        
        with open(output_file, 'w', encoding='utf-8') as out_file:
            for word, freq in word_freq.items():
                out_file.write(f'{word}: {freq}\n')
        
        print(f'Se han procesado y contado las palabras correctamente. Resultados guardados en {output_file}')
    
    except FileNotFoundError as e:
        print(f'Error: {e}')
    except IOError:
        print(f'Error al procesar el archivo "{input_file}".')

# Ejemplo de uso:
if __name__ == '__main__':
    input_file = input("Ingrese el nombre del archivo .txt que desea procesar: ")
    
    process_file(input_file)
