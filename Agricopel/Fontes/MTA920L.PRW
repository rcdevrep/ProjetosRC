#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MTA920L  � Autor � Osmar Schimitberger � Data �  14/09/2018 ���
�������������������������������������������������������������������������͹��
���Descricao � PE p/atualizar Tipo NF igual "S" servico quando o produto  ���
���          � de servico n�o tiver o cod.ISS p/n�o gerar Sped/Apur.Icms  ���
�������������������������������������������������������������������������͹��
���Uso       � Agricopel                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
     
//Atualiza��o SF3 - Cabecalho Livro Fiscal -> Necessario porque tem itens de servi�o/materiais com o mssmo c�digo
//e a Totvs trata o servico por codigo de produto (Cod. ISS) - Chamado 73351 - ROTINA DE DOCUMENTO DE ENTRADA
User Function MTA920L()
                                         
If alltrim(SF3->F3_ESPECIE)	== "NFS" .and. SF3->F3_TIPO <> "S"

   	Reclock("SF3",.F.)
   	SF3->F3_TIPO:= "S"
   	MsUnlock()

Endif    

Return()
     
//Atualiza��o SFT - Itens Livro Fiscal  -> Necessario porque tem itens de servi�o/materiais com o mssmo c�digo
//e a Totvs trata o servico por codigo de produto (Cod. ISS) - Chamado 73351 - ROTINA DE DOCUMENTO DE ENTRADA
User Function XFCD2SFT

If alltrim(SFT->FT_ESPECIE)	== "NFS" .and. SFT->FT_TIPO <> "S"

   	Reclock("SFT",.F.)
   	SFT->FT_TIPO:= "S"
   	MsUnlock()

Endif    

Return()                       
