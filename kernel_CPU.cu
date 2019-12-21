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



// ïðîâåðêà ïðåäïîëîæèòåëüíûõ êîðíåé íà  CPU
std::vector<double> result(std::vector<double> arrayR_F, int* array_F, int k) {
	std::vector<double> arrayResult;
	int n = arrayR_F.size();	

	for (int i = 0; i < n; i++) { //ïðîõîä ïî ïðåäïîëàãàåìûì êîðíÿì
		double tempResult = 0;
		for (int j = 0; j < k; j++) { //ïðîõîä ïî ñòåïåíÿì (ýëåìåíòàì) ïîëèíîìà
			tempResult += array_F[j] * pow(arrayR_F[i], k - j - 1);
		}
		if (tempResult == 0) arrayResult.push_back(arrayR_F[i]);
	}
	return arrayResult;
}





int main(void) {
	
	// êîäèðîâêà
	setlocale(0, "");

	// n ñòåïåíü ïîëèíîìà
	std::cout<< "Ââåäèòå ìàêñèìàëüíóþ ñòåïåíü ïîëèíîìà: ";
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
	std::vector<double> arrayP(1, arrayS[n-1]);
	std::vector<double> arrayQ(1, arrayS[0]);

	for (int d = (fabs(arrayS[0]) / 2) + 1; d > 1; d--)
		if (arrayS[0] % d == 0)
			arrayQ.push_back(d);

	for (int d = (fabs(arrayS[n - 1]) / 2) + 1; d > 1; d--)
		if (arrayS[n - 1] % d == 0)
			arrayP.push_back(d);

	arrayP.push_back(1);
	arrayQ.push_back(1);

	// ñîñòàâëåíèå âåêòîðà arrayR ïðåäïîëîæèòåëüíûõ êîðíåé (êîìáèíàöèé áåç ïîâòîðåíèé) èç âñåõ +- p/q 
	std::vector<double> arrayR;
	for (int ip = 0; ip < arrayP.size(); ip++){
		for (int iq = 0; iq < arrayQ.size(); iq++) {
			arrayR.push_back(double(arrayP[ip] / arrayQ[iq]));
			arrayR.push_back(double(-arrayP[ip] / arrayQ[iq]));
		}
	}

	// ñîðòèðîâêà è óáîðêà äóáëèêàòîâ èç arrayR
	std::sort(arrayR.begin(), arrayR.end());
	arrayR.erase(std::unique(arrayR.begin(), arrayR.end()), arrayR.end());

	//âûçîâ ïðîâåðêè íà CPU
	
	std::vector<double> arrayResult1;
	arrayResult1 = result(arrayR, arrayS, n);
	

	//õðåíü----------------------------------------------------------------------------------------------
	std::cout << "Äåëèòåëè p:  ";
	for (int i = 0; i < arrayP.size(); i++) {
		std::cout << arrayP[i] << ' ';
	}
	std::cout << " \n";
	std::cout << " \n";

	std::cout << "Äåëèòåëè q:  ";
	for (int i = 0; i < arrayQ.size(); i++) {
		std::cout << arrayQ[i] << ' ';
	}
	std::cout << " \n";
	std::cout << " \n";
	
	std::cout << "Ïðåäïîëàãàåìûå êîðíè:  ";
	for (int i = 0; i < arrayR.size(); i++) {
		std::cout << arrayR[i] << "   ";
	}
	std::cout << " \n";
	std::cout << " \n";

	std::cout << "Âåðíûå êîðíè CPU:  ";
	for (int i = 0; i < arrayResult1.size(); i++) {
		std::cout << arrayResult1[i] << ' ';
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
