#INCLUDE "Totvs.CH"
#INCLUDE "PROTHEUS.CH"
#Include "RwMake.ch"
#Include "Topconn.ch"
#Include "TbiConn.ch"
#Include "TbiCode.ch"

/* 
�����������������������������������������������������������������������������
Programa  � F240ADCM  �Autor  � Jader Berto         Data � 02/05/2024     ���
�����������������������������������������������������������������������������
���Desc.  �Inclus�o do Campo Valor L�quido nas linhas do Border�          ���
���                                                                       ���
���                                                                       ���
���                                                                       ���
���                                                            	         ���
���                                                                       ���
�����������������������������������������������������������������������������
���Uso    � FINA240                                                       ���
����������������������������������������������������������������������������� 
*/   

User Function F240ADCM()
Local aCamposADCM := {}

     aAdd(aCamposADCM,'E2_XVLIQ')
     
Return aCamposADCM
