#include "rwmake.ch"    

User Function AGR261()  

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//�����������������������������������������������������������������������

SetPrvt("CCADASTRO,AROTINA,")

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � AGR261   � Autor � Deco               � Data �     19/04/07���
�������������������������������������������������������������������������͹��
���Descri��o � Cadastro de Cliente x Representantes (Televendas e Lubrif.)���
�������������������������������������������������������������������������͹��
���Uso       � Espec�fico para Agricopel                                  ���
�������������������������������������������������������������������������͹��
���Arquivos  � SA1 -> Cadastro de Clientes                                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

cCadastro := "Cadastro de Clientes x Vendedor (Televendas e Lubrif.)"

aRotina   := { { "Pesquisar"    ,"AxPesqui" , 0, 1},;
               { "Alterar"      ,'ExecBlock("AGR262",.F.,.F.)' , 0, 4} }
//               { "Incluir"      ,'ExecBlock("AGRXXX",.F.,.F.)' , 0, 2} }
//               { "Visualizar"   ,'ExecBlock("AGRXXX",.F.,.F.)' , 0, 3},;
//               { "Excluir"      ,'ExecBlock("AGRXXX",.F.,.F.)' , 0, 5} }

//���������������������������������������������������������������������Ŀ
//� No caso do ambiente DOS, desenha a tela padrao de fundo             �
//�����������������������������������������������������������������������

#IFNDEF WINDOWS
    ScreenDraw("SMT050", 3, 0, 0, 0)
    @3,1 Say cCadastro Color "B/W"
#ENDIF

dbSelectArea("SA1")
dbSetOrder(1)

mBrowse( 6,1,22,75,"SA1")

Return