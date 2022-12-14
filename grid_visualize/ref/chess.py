import numpy as np
import matplotlib.pyplot as plt
import cv2 as cv

def show(img):
    if img.ndim == 2: #dim=2, gray plot
        plt.imshow(img, cmap='gray', vmin=0, vmax=255)
    else: #dim=3, RGB plot
        plt.imshow(img)
    plt.show()

def png_extract(png_path, h, w, output_name):
    bt = cv.imread(png_path, cv.IMREAD_UNCHANGED)
    tr = np.zeros((h,w), dtype=np.int32)

    f = open(output_name, 'w')
    for i in range(0,h):
        for j in range(0,w):
            #print(bt[i][j])
            if(bt[i][j][3]==0): tr[i][j]= 1
            elif(bt[i][j][0]>128): tr[i][j] = 2
            elif(bt[i][j][0]<128): tr[i][j] = 0

            f.write(str(tr[i][j])+'\n')
            print(hex(tr[i][j]))
    f.close()
    return tr

bdt_path = './grid_visualize/ref/Chess_bdt45.svg.png'
blt_path = './grid_visualize/ref/Chess_blt45.svg.png'
kdt_path = './grid_visualize/ref/Chess_kdt45.svg.png'
klt_path = './grid_visualize/ref/Chess_klt45.svg.png'
ndt_path = './grid_visualize/ref/Chess_ndt45.svg.png'
nlt_path = './grid_visualize/ref/Chess_nlt45.svg.png'
pdt_path = './grid_visualize/ref/Chess_pdt45.svg.png'
plt_path = './grid_visualize/ref/Chess_plt45.svg.png'
qdt_path = './grid_visualize/ref/Chess_qdt45.svg.png'
qlt_path = './grid_visualize/ref/Chess_qlt45.svg.png'
rdt_path = './grid_visualize/ref/Chess_rdt45.svg.png'
rlt_path = './grid_visualize/ref/Chess_rlt45.svg.png'

bdt_out_path = './grid_visualize/data/bdt.mem'
blt_out_path = './grid_visualize/data/blt.mem'
kdt_out_path = './grid_visualize/data/kdt.mem'
klt_out_path = './grid_visualize/data/klt.mem'
ndt_out_path = './grid_visualize/data/ndt.mem'
nlt_out_path = './grid_visualize/data/nlt.mem'
pdt_out_path = './grid_visualize/data/pdt.mem'
plt_out_path = './grid_visualize/data/plt.mem'
qdt_out_path = './grid_visualize/data/qdt.mem'
qlt_out_path = './grid_visualize/data/qlt.mem'
rdt_out_path = './grid_visualize/data/rdt.mem'
rlt_out_path = './grid_visualize/data/rlt.mem'

show(np.hstack([png_extract(bdt_path, 40, 40, bdt_out_path)*127, png_extract(blt_path, 40, 40, blt_out_path)*127]))
show(np.hstack([png_extract(kdt_path, 40, 40, kdt_out_path)*127, png_extract(klt_path, 40, 40, klt_out_path)*127]))
show(np.hstack([png_extract(ndt_path, 40, 40, ndt_out_path)*127, png_extract(nlt_path, 40, 40, nlt_out_path)*127]))
show(np.hstack([png_extract(pdt_path, 40, 40, pdt_out_path)*127, png_extract(plt_path, 40, 40, plt_out_path)*127]))
show(np.hstack([png_extract(qdt_path, 40, 40, qdt_out_path)*127, png_extract(qlt_path, 40, 40, qlt_out_path)*127]))
show(np.hstack([png_extract(rdt_path, 40, 40, rdt_out_path)*127, png_extract(rlt_path, 40, 40, rlt_out_path)*127]))