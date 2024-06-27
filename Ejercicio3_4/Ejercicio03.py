import os
import time

def clear_screen():
    os.system('cls' if os.name == 'nt' else 'clear')

def is_valid_integer_input(input_str):
    try:
        nums = input_str.split()
        for num in nums:
            if not num.isdigit() and not (num.startswith('-') and num[1:].isdigit()):
                return False
        return True
    except ValueError:
        return False

def read_integers():
    while True:
        clear_screen()
        nums_str = input("Ingrese los números enteros separados por espacios: ").strip()
        if not is_valid_integer_input(nums_str):
            print("Error: Ingrese solo números enteros válidos.")
            time.sleep(3)
            clear_screen()
        else:
            nums = list(map(int, nums_str.split()))
            return nums

def read_target():
    while True:
        clear_screen()
        try:
            target = int(input("Ingrese el valor objetivo: "))
            if target <= 0:
                print("Error: El valor objetivo debe ser mayor que cero.")
                time.sleep(3)
                clear_screen()
            else:
                return target
        except ValueError:
            print("Error: Ingrese un número entero para el objetivo.")
            time.sleep(3)
            clear_screen()

def find_closest_subsets(nums, target):
    closest_diff = float('inf')
    closest_subsets = []

    def backtrack(index, subset_sum, subset):
        nonlocal closest_diff, closest_subsets

        
        current_diff = abs(subset_sum - target)
        if current_diff < closest_diff:
            closest_diff = current_diff
            closest_subsets.clear()  
            closest_subsets.append(subset[:])
        elif current_diff == closest_diff:
            sorted_subset = tuple(sorted(subset))
            if sorted_subset not in set(map(tuple, closest_subsets)):
                closest_subsets.append(subset[:])

        for i in range(index, len(nums)):
            subset.append(nums[i])
            backtrack(i + 1, subset_sum + nums[i], subset)
            subset.pop()

    nums.sort()  
    backtrack(0, 0, [])

    return closest_subsets

def main():
    while True:
        nums = read_integers()
        target = read_target()

        closest_subsets = find_closest_subsets(nums, target)

        clear_screen()
        print(f"Subconjunto(s) con suma más cercana a {target}:")
        for subset in closest_subsets:
            print(subset)

        while True:
            try:
                again = input("\n¿Desea ingresar otro conjunto de datos? (s/n): ").strip().lower()
                if again == 's' or again == 'n':
                    break
                else:
                    clear_screen()
                    print("Error: Ingrese 's' para sí o 'n' para no.")
            except Exception:
                clear_screen()
                print("Error: Se produjo un error inesperado.")

        if again != 's':
            break

if __name__ == "__main__":
    main()
