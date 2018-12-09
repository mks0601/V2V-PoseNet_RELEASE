# V2V-PoseNet: Voxel-to-Voxel Prediction Network for Accurate 3D Hand and Human Pose Estimation from a Single Depth Map

PyTorch re-implementation of the V2V-PoseNet is avaiable at dragonbook's [[repo](https://github.com/dragonbook/V2V-PoseNet-pytorch)].
Thank dragonbook for re-implementation. Other versions of the V2V-PoseNet repo are also welcome!

# Introduction

This is our project repository for the paper, **V2V-PoseNet: Voxel-to-Voxel Prediction Network for Accurate 3D Hand and Human Pose Estimation from a Single Depth Map ([CVPR 2018](http://cvpr2018.thecvf.com))**.

We, **Team SNU CVLAB**, (<i>Gyeongsik Moon, Juyong Chang</i>, and <i>Kyoung Mu Lee</i> of [**Computer Vision Lab, Seoul National University**](https://cv.snu.ac.kr/)) are **winners** of [**HANDS2017 Challenge**](http://icvl.ee.ic.ac.uk/hands17/challenge/) on frame-based 3D hand pose estimation.



Please refer to our paper for details.

If you find our work useful in your research or publication, please cite our work:

[1] Moon, Gyeongsik, Ju Yong Chang, and Kyoung Mu Lee. **"V2V-PoseNet: Voxel-to-Voxel Prediction Network for Accurate 3D Hand and Human Pose Estimation from a Single Depth Map."** <i>CVPR 2018. </i> [[arXiv](https://arxiv.org/abs/1711.07399)]
  
  ```
@InProceedings{Moon_2018_CVPR_V2V-PoseNet,
  author = {Moon, Gyeongsik and Chang, Juyong and Lee, Kyoung Mu},
  title = {V2V-PoseNet: Voxel-to-Voxel Prediction Network for Accurate 3D Hand and Human Pose Estimation from a Single Depth Map},
  booktitle = {The IEEE Conference on Computer Vision and Pattern Recognition (CVPR)},
  year = {2018}
}
```

In this repository, we provide
* Our model architecture description (V2V-PoseNet)
* HANDS2017 frame-based 3D hand pose estimation Challenge Results
* Comparison with the previous state-of-the-art methods
* Training code
* Datasets we used (ICVL, NYU, MSRA, ITOP)
* Trained models and estimated results
* 3D hand and human pose estimation examples


## Model Architecture

![V2V-PoseNet](/figs/V2V-PoseNet.png)

## HANDS2017 frame-based 3D hand pose estimation Challenge Results

![Challenge_result](/figs/Challenge_result.png)


## Comparison with the previous state-of-the-art methods

![Paper_result_hand_graph](/figs/Paper_result_hand_graph.png)

![Paper_result_hand_table](/figs/Paper_result_hand_table.png)

![Paper_result_human_table](/figs/Paper_result_human_table.png)

# About our code
## Dependencies
* [Torch7](http://torch.ch)
* [CUDA](https://developer.nvidia.com/cuda-downloads)
* [cuDNN](https://developer.nvidia.com/cudnn)

Our code is tested under Ubuntu 14.04 and 16.04 environment with Titan X GPUs (12GB VRAM).

## Code
Clone this repository into any place you want. You may follow the example below.
```bash
makeReposit = [/the/directory/as/you/wish]
mkdir -p $makeReposit/; cd $makeReposit/
git clone https://github.com/mks0601/V2V-PoseNet_RELEASE.git
```
* `src` folder contains lua script files for data loader, trainer, tester and other utilities.
* `data` folder contains data converter which converts image files to the binary files.

To train our model, please run the following command in the `src` directory:

```bash
th rum_me.lua
```

* There are some optional configurations you can adjust in the config.lua. 
* You have to convert the `.png` images of the ICVL and NYU dataset to the `.bin` files by running the code from `data` folder.
* The directory where you have to put the dataset files and computed centers of each frame is defined in `src/data/dataset_name/data.lua`
* Visualization code is finally uploaded! You have to prepare 'result_pixel.txt' for each dataset. Each row of the result file has to contain the pixel coordinates of x, y and depth of all joints (i.e, x1 y1 z1 x2 y2 z2 ...). Then run pixel2world script and run draw_DB.m

# Dataset
We trained and tested our model on the four 3D hand pose estimation and one 3D human pose estimation datasets.

* ICVL Hand Poseture Dataset [[link](https://labicvl.github.io/hand.html)] [[paper](http://www.iis.ee.ic.ac.uk/dtang/cvpr_14.pdf)]
* NYU Hand Pose Dataset [[link](https://cims.nyu.edu/~tompson/NYU_Hand_Pose_Dataset.htm)] [[paper](https://cims.nyu.edu/~tompson/others/TOG_2014_paper_PREPRINT.pdf)]
* MSRA Hand Pose Dataset [[link](https://jimmysuen.github.io/)] [[paper](https://www.cv-foundation.org/openaccess/content_cvpr_2015/papers/Sun_Cascaded_Hand_Pose_2015_CVPR_paper.pdf)]
* HANDS2017 Challenge Dataset [[link](http://icvl.ee.ic.ac.uk/hands17/challenge/)] [[paper](https://arxiv.org/abs/1712.03917)] [[challenge benchmark paper](http://openaccess.thecvf.com/content_cvpr_2018/papers/Yuan_Depth-Based_3D_Hand_CVPR_2018_paper.pdf)]
* ITOP Human Pose Dataset [[link](https://www.albert.cm/projects/viewpoint_3d_pose/)] [[paper](https://arxiv.org/abs/1603.07076)]


# Results
Here we provide the precomputed centers, estimated 3D coordinates and pre-trained models.

The precomputed centers are obtained by training the hand center estimation network from [DeepPrior++ ](https://arxiv.org/pdf/1708.08325.pdf). Each line represents 3D world coordinate of each frame.
In case of ICVL, NYU, MSRA dataset, if depth map is not exist or not contain hand, that frame is considered as invalid.
In case of ITOP dataset, if 'valid' variable of a certain frame is false, that frame is considered as invalid.
All test images are considered as valid.

The 3D coordinates estimated on the ICVL, NYU and MSRA datasets are pixel coordinates and the 3D coordinates estimated on the ITOP datasets are world coordinates. The estimated results are from ensembled model. You can make the results from a single model by downloading the pre-trained model and testing it.

* ICVL Hand Poseture Dataset [[center_trainset](https://cv.snu.ac.kr/research/V2V-PoseNet/ICVL/center/center_train_refined.txt)] [[center_testset](https://cv.snu.ac.kr/research/V2V-PoseNet/ICVL/center/center_test_refined.txt)] [[estimation](https://cv.snu.ac.kr/research/V2V-PoseNet/ICVL/coordinate/result.txt)] [[models](https://cv.snu.ac.kr/research/V2V-PoseNet/ICVL/model/model.tar.gz)]
* NYU Hand Pose Dataset [[center_trainset](https://cv.snu.ac.kr/research/V2V-PoseNet/NYU/center/center_train_refined.txt)] [[center_testset](https://cv.snu.ac.kr/research/V2V-PoseNet/NYU/center/center_test_refined.txt)] [[estimation](https://cv.snu.ac.kr/research/V2V-PoseNet/NYU/coordinate/result.txt)] [[models](https://cv.snu.ac.kr/research/V2V-PoseNet/NYU/model/model.tar.gz)]
* MSRA Hand Pose Dataset [[center](https://cv.snu.ac.kr/research/V2V-PoseNet/MSRA/center/center.tar.gz)] [[estimation](https://cv.snu.ac.kr/research/V2V-PoseNet/MSRA/coordinate/result.txt)] [[models](https://cv.snu.ac.kr/research/V2V-PoseNet/MSRA/model/model.tar.gz)]
* ITOP Human Pose Dataset (front-view) [[center_trainset](https://cv.snu.ac.kr/research/V2V-PoseNet/ITOP_front/center/center_train.txt)] [[center_testset](https://cv.snu.ac.kr/research/V2V-PoseNet/ITOP_front/center/center_test.txt)] [[estimation](https://cv.snu.ac.kr/research/V2V-PoseNet/ITOP_front/coordinate/result.txt)] [[models](https://cv.snu.ac.kr/research/V2V-PoseNet/ITOP_front/model/model.tar.gz)]
* ITOP Human Pose Dataset (top-view) [[center_trainset](https://cv.snu.ac.kr/research/V2V-PoseNet/ITOP_top/center/center_train.txt)] [[center_testset](https://cv.snu.ac.kr/research/V2V-PoseNet/ITOP_top/center/center_test.txt)] [[estimation](https://cv.snu.ac.kr/research/V2V-PoseNet/ITOP_top/coordinate/result.txt)] [[models](https://cv.snu.ac.kr/research/V2V-PoseNet/ITOP_top/model/model.tar.gz)]

We used [awesome-hand-pose-estimation ](https://github.com/xinghaochen/awesome-hand-pose-estimation) to evaluate the accuracy of the V2V-PoseNet on the ICVL, NYU and MSRA dataset.

Belows are qualitative results.
![result_1](/figs/result/Paper_result_ICVL.png)
![result_2](/figs/result/Paper_result_NYU.png)
![result_3](/figs/result/Paper_result_MSRA.png)
![result_4](/figs/result/Paper_result_HANDS2017.png)
![result_5](/figs/result/Paper_result_ITOP_front.png)
![result_6](/figs/result/Paper_result_ITOP_top.png)
