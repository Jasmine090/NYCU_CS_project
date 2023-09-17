#!/usr/bin/env python
# coding: utf-8

# In[1]:


#act = list()
#for i in range(28):
    #act.append(list())
    
#idx = 0

#f = open('1.txt')
#for line in f.readlines():
    #act[idx//28].append(int(line, 0))
    #idx += 1;
#f.close()


# In[2]:


#w = list()
#for i in range(16):
    #w.append(list())
    
#idx = 0
    
#f = open('w_text.txt')
#for line in f.readlines():
    #w[idx//16].append(float(line))
    #idx += 1
#f.close()


# In[3]:


#psum = list()
#for i in range(13):
    #psum.append(list())
    
#idx = 0
    
#f = open('result_text.txt')
#for line in f.readlines():
    #psum[idx//13].append(float(line))
    #idx += 1
#f.close()


# In[4]:


#import numpy as np
#from scipy import fftpack,signal

#x = np.array(act)
#h = np.array(w)
#y = signal.convolve(x, h, mode = "valid")
#for i in range(13):
#    for j in range(13):
#        print(y[i][j])


# In[6]:


#s = list()
#for i in range(13):
    #s.append(list())
    
    
#for i in range(13):
    #for j in range(13):
        #s[i].append(0);
        #for k in range(16):
            #for t in range(16):
                #if act[i+k][j+t] != 0:
                    #print(k, t, act[i+k][j+t], w[k][t])
                #s[i][j] += act[i+k][j+t] * w[k][t]
                


# In[7]:


#for i in range(13):
    #for j in range(13):
        #print(s[i][j])


# In[8]:


#s1 = list()
#s2 = list()
#s3 = list()
#s4 = list()

#i = 0
#j = 0
    
#for k in range(0, 8):
#    s1.append(0)
#    for t in range(0, 8):
#        s1[k] += act[i+k][j+t] * w[k][t]
                
#for k in range(0, 8):
#    s2.append(0)
#    for t in range(8, 16):
#        s2[k] += act[i+k][j+t] * w[k][t]
                
#for k in range(8, 16):
#    s3.append(0)
#    for t in range(0, 8):
#        s3[k-8] += act[i+k][j+t] * w[k][t]
                
#for k in range(8, 16):
#    s4.append(0)
#    for t in range(8, 16):
#        s4[k-8] += act[i+k][j+t] * w[k][t]
                
#print(s1[0], s1[1], s1[2], s1[3], s1[4], s1[5], s1[6], s1[7])
#print(s2[0], s2[1], s2[2], s2[3], s2[4], s2[5], s2[6], s2[7])
#print(s3[0], s3[1], s3[2], s3[3], s3[4], s3[5], s3[6], s3[7])
#print(s4[0], s4[1], s4[2], s4[3], s4[4], s4[5], s4[6], s4[7])


# In[1]:


import os
for dirname, _, filenames in os.walk('inputs'):
    for filename in filenames:
        print(os.path.join(dirname, filename))


# In[4]:


w = list()
for i in range(16):
    w.append(list())
    
idx = 0
    
f = open('w_text.txt')
for line in f.readlines():
    w[idx//16].append(float(line))
    idx += 1
f.close()


# In[5]:


for dirname, _, filenames in os.walk('inputs-hex'):
    for filename in filenames:
        f = open(os.path.join(dirname, filename), "r")
        act = list()
        for i in range(28):
            act.append(list())
            
        idx = 0
        
        for line in f.readlines():
            act[idx//28].append(int(line, 0))
            idx += 1;
        f.close()
        
        psum = list()
        for i in range(13):
            psum.append(list())

        idx = 0

        f = open('outputs/' + filename[:-4] + '-result.txt')
        for line in f.readlines():
            psum[idx//13].append(float(line))
            idx += 1
        f.close()
        
        s = list()
        for i in range(13):
            s.append(list())


        for i in range(13):
            for j in range(13):
                s[i].append(0);
                for k in range(16):
                    for t in range(16):
                        s[i][j] += act[i+k][j+t] * w[k][t]
                        
        for i in range(13):
            for j in range(13):
                #print(s[i][j])
                if round(s[i][j], 5) != psum[i][j]:
                    print("file " + filename + " error: ", i, j)
        print("file " + filename + " : No Error")


# In[ ]:




