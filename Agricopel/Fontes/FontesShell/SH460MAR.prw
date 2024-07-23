#INCLUDE "TOTVS.CH"

/*
//�����������������������������������������������������������������������������������������������������������Ŀ
//�Personalizado por Max Ivan (Nexus) em 27/12/2018, para tratamento deste fonte dentro do PE M460MARK        �
//�Obs: Os par�metros da rotina (PE) original (M460MARK), est�o como primeiro par�metro desta rotina SH460MAR.�
//�     Sendo assim, os par�metros ficam conforme exemplo abaixo:                                             �
//�     	NO FONTE ORIGINAL M460MARK			AQUI NESTE FONTE SH460MARK                                    �
//�				ParamIxb[1]							ParamIxb[1,1]                                             �
//�				ParamIxb[2]							ParamIxb[1,2]                                             �
//�Obs2: O retorno do fonte original est� no segundo par�metro (ParamIxb[2])                                  �
//�������������������������������������������������������������������������������������������������������������
*/
User Function SH460MAR()

    Local _lRet := ParamIxb[2]

Return(_lRet)