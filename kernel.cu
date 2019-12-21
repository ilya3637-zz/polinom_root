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



// проверка предположительных корней на  CPU
std::vector<double> result(std::vector<double> arrayR_F, int* array_F, int k) {
	std::vector<double> arrayResult;
	int n = arrayR_F.size();	

	for (int i = 0; i < n; i++) { //проход по предполагаемым корням
		double tempResult = 0;
		for (int j = 0; j < k; j++) { //проход по степеням (элементам) полинома
			tempResult += array_F[j] * pow(arrayR_F[i], k - j - 1);
		}
		if (tempResult == 0) arrayResult.push_back(arrayR_F[i]);
	}
	return arrayResult;
}





int main(void) {
	
	// кодировка
	setlocale(0, "");

	// n степень полинома
	std::cout<< "Введите максимальную степень полинома: ";
	int n;
	std::cin >> n;
	n++;
	int* arrayS = new int[n];

	// Ввод массива с клавиатуры
	for (int i = 0; i < n; i++)
	{
		std::cin >> arrayS[i];
	}

	unsigned int start_time = clock();
	// Вывод F на экран
	std::cout << " F = ";
	for (int i = 0; i < n; i++)
	{
		if (arrayS[i] >= 0) 
			std::cout << " + " << arrayS[i] << " * x^" << (n - 1 - i) << " ";
		else
			std::cout << arrayS[i] << "*x^" << (n - 1 - i) << " ";
	}
	std::cout << " = 0\n";

	// поиска делителей p=array[0], q=array[n-1] и запись их в вектора
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

	// составление вектора arrayR предположительных корней (комбинаций без повторений) из всех +- p/q 
	std::vector<double> arrayR;
	for (int ip = 0; ip < arrayP.size(); ip++){
		for (int iq = 0; iq < arrayQ.size(); iq++) {
			arrayR.push_back(double(arrayP[ip] / arrayQ[iq]));
			arrayR.push_back(double(-arrayP[ip] / arrayQ[iq]));
		}
	}

	// сортировка и уборка дубликатов из arrayR
	std::sort(arrayR.begin(), arrayR.end());
	arrayR.erase(std::unique(arrayR.begin(), arrayR.end()), arrayR.end());

	//вызов проверки на CPU
	
	std::vector<double> arrayResult1;
	arrayResult1 = result(arrayR, arrayS, n);
	

	//хрень----------------------------------------------------------------------------------------------
	std::cout << "Делители p:  ";
	for (int i = 0; i < arrayP.size(); i++) {
		std::cout << arrayP[i] << ' ';
	}
	std::cout << " \n";
	std::cout << " \n";

	std::cout << "Делители q:  ";
	for (int i = 0; i < arrayQ.size(); i++) {
		std::cout << arrayQ[i] << ' ';
	}
	std::cout << " \n";
	std::cout << " \n";
	
	std::cout << "Предполагаемые корни:  ";
	for (int i = 0; i < arrayR.size(); i++) {
		std::cout << arrayR[i] << "   ";
	}
	std::cout << " \n";
	std::cout << " \n";

	std::cout << "Верные корни CPU:  ";
	for (int i = 0; i < arrayResult1.size(); i++) {
		std::cout << arrayResult1[i] << ' ';
	}
	std::cout << " \n";
	std::cout << " \n";
	//конец хрени----------------------------------------------------------------------------------------------


	
	// время исполнения
	unsigned int end_time = clock();
	unsigned int search_time = end_time - start_time;
	std::cout << "Время работы общее " << search_time << " милисекунд \n";
	system("pause");
	return 0;
}