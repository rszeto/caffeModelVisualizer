# Caffe model visualizer

This software lets you visualize Caffe models, specifically the convolutional kernels and weights for fully-connected layers of pre-trained models.

## Running the program

### Requirements

This program requires MATLAB and Caffe. It was tested on MATLAB R2015b and Caffe 1.0.0 RC3, but it _should_ work for earlier versions of both.

### Starting the GUI

1. Download the code (duh).
2. Move or copy `startup.m.example` to `startup.m`.
3. In `startup.m`, change the variable `g_caffePath` to the `matlab` folder under your Caffe installation.
4. (Optional) In `startup.m`, change the variable `g_modelRootPath` to the folder where you store your models. You don't necessarily have to set it to your model path, but since this determines the starting location of the GUI's file chooser (and nothing more), you should set this to a convenient location.
5. If needed, add the `lib` folder under your Caffe installation to your shared library path. On Linux, this can be done as follows:

	```
	# Add Caffe to shared path
	export LD_LIBRARY_PATH=/home/rszeto/caffe/lib:$LD_LIBRARY_PATH
	```

6. Run `startup.m`.

## More information

Further instructions on using the GUI itself appear when you run the program.
