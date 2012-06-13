      SUBROUTINE MAG152(N9,N10,NOMRES,NUGENE,MODMEC,MODGEN,NBLOC,
     &                  INDICE)
      IMPLICIT NONE
C---------------------------------------------------------------------
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
C---------------------------------------------------------------------
C AUTEUR : G.ROUSSEAU
C CREATION DE LA MATRICE ASSEMBLEE GENERALISEE AU FORMAT LDLT :
C      - OBJET    .UALF
C      - STOCKAGE .SLCS
C ET REMPLISSAGE DE SES OBJETS AUTRES QUE LE .UALF
C---------------------------------------------------------------------
      INCLUDE 'jeveux.h'
      INTEGER INDICE,IMODEG
      INTEGER JREFA,I,ISCBL,IACONL
      INTEGER IALIME,IBLO
      INTEGER ISCHC
      INTEGER SOMME
      INTEGER JSCDE,N1BLOC,N2BLOC
      INTEGER NBID,NBLOC,NTBLOC,NUEQ,NHMAX
      INTEGER N9,N10
      CHARACTER*8 NOMRES,K8BID,MODMEC,NUMMOD
      CHARACTER*8 MODGEN
      CHARACTER*14 NUM14,NUGENE
      CHARACTER*19 NOMSTO
      INTEGER      IARG
C -----------------------------------------------------------------
C
C        CAS NUME_DDL_GENE  PRESENT
C
      CALL JEMARQ()

      CALL WKVECT(NOMRES//'           .REFA','G V K24',11,JREFA)
      ZK24(JREFA-1+11)='MPI_COMPLET'
      NOMSTO=NUGENE//'.SLCS'

      IF ((N9.GT.0)) THEN
        CALL JEVEUO(NOMSTO//'.SCDE','L',JSCDE)
        NUEQ = ZI(JSCDE-1+1)
        NTBLOC = ZI(JSCDE-1+2)
        NBLOC = ZI(JSCDE-1+3)
        NHMAX = ZI(JSCDE-1+4)


C TEST SUR LE MODE DE STOCKAGE : SI ON N EST PAS EN STOCKAGE
C LIGNE DE CIEL PLEIN ON PLANTE

        IF (NUEQ.NE.NHMAX) THEN
          CALL U2MESS('A','ALGORITH5_16')
        END IF

        IF ((NUEQ* (NUEQ+1)/2).GT. (NBLOC*NTBLOC)) THEN
          CALL U2MESS('F','ALGORITH5_17')
        END IF

C CALCUL DU NOMBRE DE TERME PAR BLOC ET TOTAL

        CALL JEVEUO(NOMSTO//'.SCBL','L',ISCBL)
        CALL JEVEUO(NOMSTO//'.SCHC','L',ISCHC)

        SOMME = 0

        DO 20 IBLO = 1,NBLOC

C----------------------------------------------------------------
C
C         BOUCLE SUR LES COLONNES DE LA MATRICE ASSEMBLEE
C
          N1BLOC = ZI(ISCBL+IBLO-1) + 1
          N2BLOC = ZI(ISCBL+IBLO)
C
C
          DO 10 I = N1BLOC,N2BLOC
            SOMME = SOMME + ZI(ISCHC+I-1)
   10     CONTINUE
   20   CONTINUE

        WRITE (6,*) 'SOMME=',SOMME
        IF ((NUEQ* (NUEQ+1)/2).NE.SOMME) THEN
          CALL U2MESS('F','ALGORITH5_18')
        END IF



        CALL JECREC(NOMRES//'           .UALF','G V R','NU','DISPERSE',
     &              'CONSTANT',NBLOC)
        CALL JEECRA(NOMRES//'           .UALF','LONMAX',NTBLOC,K8BID)


        CALL WKVECT(NOMRES//'           .LIME','G V K24',1,IALIME)
        CALL WKVECT(NOMRES//'           .CONL','G V R',NUEQ,IACONL)
C
C       CAS DU CHAM_NO
C
      ELSE
C
        CALL JEVEUO(NOMSTO//'.SCDE','L',JSCDE)
        NUEQ = ZI(JSCDE-1+1)
        NBLOC = 1
        NTBLOC = NUEQ* (NUEQ+1)/2

        CALL JECREC(NOMRES//'           .UALF','G V R','NU','DISPERSE',
     &              'CONSTANT',NBLOC)
        CALL JEECRA(NOMRES//'           .UALF','LONMAX',NTBLOC,K8BID)
        CALL WKVECT(NOMRES//'           .LIME','G V K24',1,IALIME)
        CALL WKVECT(NOMRES//'           .CONL','G V R',NUEQ,IACONL)

      END IF

C ----------- REMPLISSAGE DU .REFA ET DU .LIME---------------
C---------------------ET DU .CONL ---------------------------


      IF (N10.GT.0) THEN
        ZK24(JREFA-1+1) = ' '

      ELSE IF (INDICE.EQ.1) THEN
        CALL GETVID(' ','NUME_DDL_GENE',0,IARG,1,NUMMOD,NBID)
        NUM14 = NUMMOD
        CALL JEVEUO(NUM14//'.NUME.REFN','L',IMODEG)
        ZK24(JREFA-1+1) = ZK24(IMODEG)

      ELSE
        ZK24(JREFA-1+1) = MODMEC
      END IF

      ZK24(JREFA-1+2) = NUGENE
      ZK24(JREFA-1+9) = 'MS'
      ZK24(JREFA-1+10) = 'GENE'

      IF (N10.GT.0) THEN
        ZK24(IALIME) = MODGEN

      ELSE
        ZK24(IALIME) = '  '
      END IF

      DO 30 I = 1,NUEQ
        ZR(IACONL+I-1) = 1.0D0
   30 CONTINUE

      CALL JEDEMA()
      END
