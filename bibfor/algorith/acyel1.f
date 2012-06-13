      SUBROUTINE ACYEL1(NMCOLZ,NOMOBZ,NOBL,NOBC,OKPART,LILIG,NBLIG,
     &LICOL,NBCOL,CMAT,NDIM,IDEB,JDEB,X)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 13/06/2012   AUTEUR COURTOIS M.COURTOIS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2012  EDF R&D                  WWW.CODE-ASTER.ORG
C THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
C IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
C THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR   
C (AT YOUR OPTION) ANY LATER VERSION.                                 
C
C THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT 
C WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF          
C MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU    
C GENERAL PUBLIC LICENSE FOR MORE DETAILS.                            
C
C YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE   
C ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,       
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.      
C ======================================================================
      IMPLICIT REAL*8 (A-H,O-Z)
C
C***********************************************************************
C    P. RICHARD     DATE 10/04/91
C-----------------------------------------------------------------------
C  BUT:  ASSEMBLER SI ELLE EXISTE LA SOUS-MATRICE  CORRESPONDANT
C  A UN NOM OBJET DE COLLECTION DANS UNE MATRICE COMPLEXE AVEC
C   UN ASSEMBLAGE EN UN TEMPS (ADAPTE AU CYCLIQUE)
C
C  SI OKPART VRAI ON ASSEMBLE QUE LA LISTE DE LIGNE ET DE COLONNES
C                 DONNEES
C
C  SI OKPART FAUX ON ASSEMBLE TOUT
C
C-----------------------------------------------------------------------
C
C NMCOLZ   /I/: NOM K24 DE LA COLLECTION
C NOMOBZ   /I/: NOM K8 DE L'OBJET DE COLLECTION
C NOBL     /I/: NOMBRE DE LIGNE DE LA MATRICE ELEMENTAIRE
C NOBC     /I/: NOMBRE DE COLONNES DE LA MATRICE ELEMENTAIRE
C OKPART   /I/: INDICATEUR SI ASSEMBLAGE PARTIEL
C LILIG    /I/: LISTE DES INDICE DE LIGNE A ASSEMBLER (SI OKPART=TRUE)
C NBLIG    /I/: NOMBRE DE LIGNES DE LA LISTE
C LICOL    /I/: LISTE INDICES DE COLONNES A ASSEMBLER (SI OKPART=TRUE)
C NBLIG    /I/: NOMBRE DE COLONNES DE LA LISTE
C CMAT     /M/: MATRICE RECEPTRICE COMPLEXE
C NDIM     /I/: DIMENSION DE LA MATRICE RECEPTRICE CARREE
C IDEB     /I/: INDICE DE PREMIERE LIGNE RECEPTRICE
C JDEB     /I/: INDICE DE PREMIERE COLONNE RECEPTRICE
C X        /I/: COEFFICIENT ASSEMBLAGE
C
C
C
      INCLUDE 'jeveux.h'
C
C
      CHARACTER*8 NOMOB
      CHARACTER*24 NOMCOL
      COMPLEX*16   CMAT(NDIM,NDIM)
      CHARACTER*(*) NMCOLZ, NOMOBZ
      INTEGER LILIG(NBLIG),LICOL(NBCOL)
      LOGICAL OKPART
C
C-----------------------------------------------------------------------
C-----------------------------------------------------------------------
C
      CALL JEMARQ()
      NOMOB = NOMOBZ
      NOMCOL = NMCOLZ
C
      CALL JENONU(JEXNOM(NOMCOL(1:15)//'.REPE.MAT',NOMOB),IRET)
      IF (IRET.EQ.0) GOTO 9999
C
        CALL JENONU(JEXNOM(NOMCOL(1:15)//'.REPE.MAT',NOMOB),IBID)
        CALL JEVEUO(JEXNUM(NOMCOL,IBID),'L',LLOB)
C
      IF(OKPART) THEN
C
C SI ASSEMBLAGE PARTIEL ON TRAITE LIGNE PAR LIGNE
C        ET COLONNE PAR COLONNE
C
        DO 10 J=1,NBCOL
          DO 20 I=1,NBLIG
            IAD=LLOB+(LICOL(J)-1)*NOBL+LILIG(I)-1
            CALL AMPCPR(CMAT,NDIM,NDIM,ZR(IAD),1,1,IDEB+I-1,JDEB+J-1,
     &                  X,1,1)
20        CONTINUE
10      CONTINUE
C
      ELSE
C
C  SI ASSEMBLAGE COMPLET ON TRAITE TOUT D'UN COUP
C
        CALL AMPCPR(CMAT,NDIM,NDIM,ZR(LLOB),NOBL,NOBC,IDEB,JDEB,X,1,1)
C
      ENDIF
C
C
 9999 CONTINUE
      CALL JEDEMA()
      END
