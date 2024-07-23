#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MTA920L  º Autor ³ Osmar Schimitberger º Data ³  14/09/2018 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ PE p/atualizar Tipo NF igual "S" servico quando o produto  º±±
±±º          ³ de servico não tiver o cod.ISS p/não gerar Sped/Apur.Icms  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Agricopel                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
     
//Atualização SF3 - Cabecalho Livro Fiscal -> Necessario porque tem itens de serviço/materiais com o mssmo código
//e a Totvs trata o servico por codigo de produto (Cod. ISS) - Chamado 73351 - ROTINA DE DOCUMENTO DE ENTRADA
User Function MTA920L()
                                         
If alltrim(SF3->F3_ESPECIE)	== "NFS" .and. SF3->F3_TIPO <> "S"

   	Reclock("SF3",.F.)
   	SF3->F3_TIPO:= "S"
   	MsUnlock()

Endif    

Return()
     
//Atualização SFT - Itens Livro Fiscal  -> Necessario porque tem itens de serviço/materiais com o mssmo código
//e a Totvs trata o servico por codigo de produto (Cod. ISS) - Chamado 73351 - ROTINA DE DOCUMENTO DE ENTRADA
User Function XFCD2SFT

If alltrim(SFT->FT_ESPECIE)	== "NFS" .and. SFT->FT_TIPO <> "S"

   	Reclock("SFT",.F.)
   	SFT->FT_TIPO:= "S"
   	MsUnlock()

Endif    

Return()                       
