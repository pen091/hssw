with open("example.txt", "r") as file:
    data = file.read()
    print("First read:", data)
    
    file.seek(0)  # Move to the beginning
    data_again = file.read()
    print("Second read:", data_again)
