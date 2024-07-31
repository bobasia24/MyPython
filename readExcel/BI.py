import matplotlib.pyplot as plt
from matplotlib.patches import Polygon
from matplotlib.text import TextPath
from matplotlib.font_manager import FontProperties
from matplotlib.transforms import Affine2D
import numpy as np

# Create figure and axis
fig, ax = plt.subplots()

# Define the color and the shape of the zongzi (a triangle for simplicity)
zongzi_color = "#FFD700"  # Gold color (close to yellow)
zongzi_points = np.array([[0, 0], [1, 2], [2, 0]])  # Define triangle points

# Create the zongzi shape
zongzi = Polygon(zongzi_points, closed=True, color=zongzi_color, edgecolor='black', linewidth=2)
ax.add_patch(zongzi)

# Add the text "榴芒一刻"
font_prop = FontProperties(fname='/usr/share/fonts/truetype/arphic/uming.ttc', size=20)  # Path to a Chinese font
text_path = TextPath((0.5, 0.5), "榴芒一刻", prop=font_prop, size=15)
trans = Affine2D().rotate_deg(0).translate(0.5, 1)
text_patch = Polygon(trans.transform_path(text_path.vertices), facecolor='black')

ax.add_patch(text_patch)

# Set limits and hide axes
ax.set_xlim(-1, 3)
ax.set_ylim(-1, 3)
ax.axis('off')

# Display the plot
plt.show()
