#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>
#include <cstdlib>
#include <cuda_runtime_api.h>
#include <iostream>
#include <windows.h>
#include <device_functions.h>
#include <cuda.h>
#include<clocale>
#include <cmath>
#include "cuda_runtime.h"
#include <vector>
#include <iomanip>
#include <ctime>
#include <algorithm>
#include <set>


// ïðîâåðêà ïðåäïîëîæèòåëüíûõ êîðíåé íà  GPU
__global__ void resultGPU(double* devarrayRR, int temp_n, int* arrayS, int k) {

	int i = blockDim.x * blockIdx.x + threadIdx.x;
	int j = blockDim.y * blockIdx.y + threadIdx.y;
	double tempResult = blockDim.z * blockIdx.z + threadIdx.z;

	for (int i = 0; i < temp_n; i++) {
		tempResult = 0;
		for (int j = 0; j < k; j++) {
			tempResult += arrayS[j] * pow(devarrayRR[i], k - j - 1);
		}
		if (tempResult != 0) devarrayRR[i] = 0;
	}
}

// ïîèñêà äåëèòåëåé p=array[0], q=array[n-1] è çàïèñü èõ â âåêòîð íà GPU
__global__ void pqr(double* devArrayP, double* devArrayQ, double* devArrayR, int p, int q) {

	int i = blockDim.x * blockIdx.x + threadIdx.x; 
	int d = blockDim.y * blockIdx.y + threadIdx.y;
	i = 1;
	devArrayQ[0] = 1;
	if (q < 0) q = q * (-1);
	for (d = (q / 2) + 1; d > 1; d--)
		if (q % d == 0) {
			devArrayQ[i] = d;
			i++;
		}

	i = 1;
	devArrayP[0] = 1;
	if (p < 0) p = p * (-1);
	for (d = (p / 2) + 1; d > 1; d--)
		if (p % d == 0) {
			devArrayP[i] = d;
			i++;
		}

	i = 0;
	for (int ip = 0; ip < 100; ip++) {
		for (int iq = 0; iq < 100; iq++) {	
			if ((devArrayP[ip] != 0) && (devArrayQ[iq] != 0)) {
				devArrayR[i] = devArrayP[ip] / devArrayQ[iq];
				i++;
				devArrayR[i] = -devArrayP[ip] / devArrayQ[iq];
				i++;
			}
		}
	}



}

int main(void) {

	// êîäèðîâêà
	setlocale(0, "");

	// n ñòåïåíü ïîëèíîìà
	std::cout << "Ââåäèòå ìàêñèìàëüíóþ ñòåïåíü ïîëèíîìà: ";
	int n;
	std::cin >> n;
	n++;
	int* arrayS = new int[n];

	// Ââîä ìàññèâà ñ êëàâèàòóðû
	for (int i = 0; i < n; i++)
	{
		std::cin >> arrayS[i];
	}

	unsigned int start_time = clock();
	// Âûâîä F íà ýêðàí
	std::cout << " F = ";
	for (int i = 0; i < n; i++)
	{
		if (arrayS[i] >= 0)
			std::cout << " + " << arrayS[i] << " * x^" << (n - 1 - i) << " ";
		else
			std::cout << arrayS[i] << "*x^" << (n - 1 - i) << " ";
	}
	std::cout << " = 0\n";

	// ïîèñêà äåëèòåëåé p=array[0], q=array[n-1] è çàïèñü èõ â âåêòîðà
	double* arrayPP = new double[100];
	double* arrayQQ = new double[100];
	double* arrayRR = new double[10000];
	for (int i = 0; i < 100; i++) {
		arrayPP[i] = 0;
	}
	for (int i = 0; i < 100; i++) {
		arrayQQ[i] = 0;
	}
	for (int i = 0; i < 1000; i++) {
		arrayRR[i] = 0;
	}
	double* devArrayP;
	double* devArrayQ;
	double* devArrayR;

	cudaMalloc((void**)&devArrayP, sizeof(double)*100);
	cudaMalloc((void**)&devArrayQ, sizeof(double) * 100);
	cudaMalloc((void**)&devArrayR, sizeof(double) * 10000);

	pqr <<< 1, 1 >>>(devArrayP, devArrayQ, devArrayR, arrayS[n - 1], arrayS[0]);
	cudaMemcpy(arrayRR, devArrayR, sizeof(double)*10000, cudaMemcpyDeviceToHost);
	cudaMemcpy(arrayPP, devArrayP, sizeof(double) * 100, cudaMemcpyDeviceToHost);
	cudaMemcpy(arrayQQ, devArrayQ, sizeof(double) * 100, cudaMemcpyDeviceToHost);
	cudaFree(devArrayP);
	cudaFree(devArrayQ);
	cudaFree(devArrayR);


	//âûçîâ ïðîâåðêè íà GPU	
	double* devarrayRR;
	int* devArrayS;
	cudaMalloc((void**)&devarrayRR, sizeof(double)*10000);
	cudaMalloc((void**)&devArrayS, n * sizeof(int));
	cudaMemcpy(devarrayRR, arrayRR, sizeof(double)*10000, cudaMemcpyHostToDevice);
	cudaMemcpy(devArrayS, arrayS, sizeof(int)*n, cudaMemcpyHostToDevice);

	resultGPU <<< 100, 100 >>>(devarrayRR, 10000, devArrayS, n);

	cudaMemcpy(arrayRR, devarrayRR, sizeof(double)*10000, cudaMemcpyDeviceToHost);
	cudaFree(devarrayRR);



	//õðåíü----------------------------------------------------------------------------------------------
	std::cout << "Äåëèòåëè p:  ";
	for (int i = 0; i < 100; i++) {
		if (arrayPP[i] != 0) std::cout << arrayPP[i] << ' ';
	}
	std::cout << " \n";
	std::cout << " \n";

	std::cout << "Äåëèòåëè q:  ";
	for (int i = 0; i < 100; i++) {
		if (arrayQQ[i] != 0) std::cout << arrayQQ[i] << ' ';
	}
	std::cout << " \n";
	std::cout << " \n";

	std::cout << "Ïðåäïîëàãàåìûå êîðíè:  ";
	for (int i = 0; i < 10000; i++) {
		if (arrayRR[i] != NULL) std::cout << arrayRR[i] << "   ";
	}
	std::cout << " \n";
	std::cout << " \n";

	std::cout << "Âåðíûå êîðíè GPU:  ";
	for (int i = 0; i < 10000; i++) {
		if (arrayRR[i] != 0) std::cout << arrayRR[i] << ' ';
	}
	std::cout << " \n";
	std::cout << " \n";
	//êîíåö õðåíè----------------------------------------------------------------------------------------------



	// âðåìÿ èñïîëíåíèÿ
	unsigned int end_time = clock();
	unsigned int search_time = end_time - start_time;
	std::cout << "Âðåìÿ ðàáîòû îáùåå " << search_time << " ìèëèñåêóíä \n";
	system("pause");
	return 0;
}
