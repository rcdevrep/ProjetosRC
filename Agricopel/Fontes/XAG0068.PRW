#include 'protheus.ch'
#include 'PRTOPDEF.CH'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �XAG0068   �Autor  �Osmar Schimitberger � Data �  25/06/2020 ���
�������������������������������������������������������������������������͹��
���Desc.     �  Programa para Credito - LP 650-009-entradas de bonifica��o���
�������������������������������������������������������������������������͹��
���Uso       � Agricopel                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function XAG0068()

	Private cCtaCre:= "52111923"
                   
    If SB1->B1_TIPO=="CO"
       
       cCtaCre:= "51210101"
       
    Endif   
       
    If SB1->B1_TIPO$"SH"
    
       cCtaCre:= "51210105"
    
    Endif

   If SB1->B1_TIPO$"LU"
    
       cCtaCre:= "51210102"
    
    Endif
    
    If SB1->B1_TIPO$"UR"
    
       cCtaCre:= "51210134"
    
    Endif
    
    If SB1->B1_TIPO=="AG"
    
       cCtaCre:= "51210106"
       
    Endif   
    
    If SB1->B1_TIPO=="PA"
    
       cCtaCre:= "51210107"
       
    Endif   
       
    If SB1->B1_TIPO=="VE"
    
       cCtaCre:= "51210108"
    
    Endif
    
    If SB1->B1_TIPO=="LO"
    
       cCtaCre:= "51210118"
    
    Endif
    
    If SB1->B1_TIPO=="MM"
    
       cCtaCre:= "51210120"
       
    Endif
    
    // gentileza acrescentar tipo QR: 51210110, MK: 51210122, AE: 51210123  E quando o b1_tipo n�o for nenhum destes a conta ser� 52111923
   
    If SB1->B1_TIPO=="QR"
    
       cCtaCre:= "51210110"
       
    Endif
   
    If SB1->B1_TIPO=="MK"
    
       cCtaCre:= "51210122"
       
    Endif
    
    If SB1->B1_TIPO=="AE"
    
       cCtaCre:= "51210123"
       
    Endif

   //Carlos Savio - Chamado 515131 - ALTERA��O DE LAN�AMENTO PADR�O - Bruna Bassani
   //Precisamos alterar a regra e incluir os seguinte dados - Tipo "IA" - Conta 51210132.

    If SB1->B1_TIPO=="IA"
    
       cCtaCre:= "51210132"
       
    Endif
Return(cCtaCre)
