from tensorflow.keras.datasets import mnist
import numpy as np
import matplotlib.pyplot as plt

(x_train, y_train), _ = mnist.load_data()

for digit in range(10):

    idx = np.where(y_train == digit)[0][0]

    img = x_train[idx]

    # 🔥 NORMALIZAÇÃO PARA HARDWARE
    img = (img >> 4).astype(int)

    print(f"\nDigit: {digit}")
    print("Min:", img.min(), "Max:", img.max())

    plt.imshow(img, cmap='gray')
    plt.title(f"Digit {digit}")
    plt.show()

    flat = img.flatten()

    with open(f"../data/input_{digit}.mem", "w") as f:
        for val in flat:
            f.write(f"{val:02x}\n")