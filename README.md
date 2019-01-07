# final-year-project
In this project, I aim at applying transfer learning on EEG in order to show significant differences between Parkinson's Disease patients and normal control and build classification model. 
Dr. X WH (though not obtained the degree yet) is working together with me on this topic. 
He is focusing on data augmentation based on GAN. 
The dataset we are using is from [Pred+ct](http://predict.cs.unm.edu/). 
We decided to select **channels around Cz (Pz, Cz, Fz, P3, C3, F3, P4, C4, F4)** as we believe this region is greatly related to cognitive functions.

Why hdf5 files?

Because when I tried to save them as .mat files, the size of the file was strangely huge.
I didn't spend time finding the reason, and hdf5 is a second choice as a bridge between Matlab and Python.

The disappointing thing is that there is always some trivia in the final year thus I cannot fully focus on the project. 
This week I tried to build models and the dataloader. 
Dataloader is always something bloated. 
In the past, I built it and ended up with too many parameters. 
This time I tried to make it as light as possible but it seems that I failed to make differences.
