      SUBROUTINE TE0322(OPTION,NOMTE)

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 17/12/2012   AUTEUR LAVERNE J.LAVERNE 
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
C   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C RESPONSABLE LAVERNE J.LAVERNE

      IMPLICIT NONE
      INCLUDE 'jeveux.h'
      CHARACTER*16 NOMTE,OPTION

C-----------------------------------------------------------------------
C     BUT : CALCUL DES OPTIONS NON LINEAIRES DES ELEMENTS DE JOINT HM
C     OPTION : RAPH_MECA, FULL_MECA, RIGI_MECA_TANG, RIGI_MECA_ELAS
C-----------------------------------------------------------------------


      INTEGER NDIM,NNO1,NNO2,NNOS,NPG,NDDL,NTROU
      INTEGER IW,IVF1,IVF2,IDF1,IDF2,JGN
      INTEGER IGEOM,IMATER,ICARCR,ICOMP,IDDLM,IDDLD
      INTEGER ICONTM,ICONTP,IVECT,IMATR,IU(3,16),IP(4)
      INTEGER IVARIM,IVARIP,JTAB(7),IRET,IINSTM,IINSTP
      INTEGER LGPG1,LGPG
      CHARACTER*8 TYPMOD(2),LIELRF(10)
      LOGICAL RESI,RIGI

      RESI = OPTION.EQ.'RAPH_MECA' .OR. OPTION(1:9).EQ.'FULL_MECA'
      RIGI = OPTION(1:9).EQ.'FULL_MECA' .OR. OPTION(1:9).EQ.'RIGI_MECA'

C FONCTIONS DE FORMES ET POINTS DE GAUSS
      CALL ELREF2(NOMTE,2,LIELRF,NTROU)
      CALL ELREF4(LIELRF(1),'RIGI',NDIM,NNO1,NNOS,NPG,IW,IVF1,IDF1,JGN)
      CALL ELREF4(LIELRF(2),'RIGI',NDIM,NNO2,NNOS,NPG,IW,IVF2,IDF2,JGN)

C LA DIMENSION DE L'ESPACE EST CELLE DE L'ELEM DE REF SURFACIQUE PLUS 1
      NDIM = NDIM + 1

C NB DE DDL = NDIM PAR NOEUD DE DEPL + UN PAR NOEUD DE PRES
      NDDL = NDIM*2*NNO1 + NNO2

C DECALAGE D'INDICE POUR LES ELEMENTS DE JOINT HM
      CALL EJINIT(NOMTE,IU,IP)

C TYPE DE MODELISATION
      IF (NDIM.EQ.3) THEN
        TYPMOD(1) = '3D'
      ELSE
        TYPMOD(1) = 'PLAN'
      ENDIF
      TYPMOD(2) = 'EJ_HYME'

C DONNEES EN ENTREE
      CALL JEVECH('PGEOMER','L',IGEOM)
      CALL JEVECH('PMATERC','L',IMATER)
      CALL JEVECH('PCARCRI','L',ICARCR)
      CALL JEVECH('PCOMPOR','L',ICOMP)
      CALL JEVECH('PDEPLMR','L',IDDLM)
      CALL JEVECH('PDEPLPR','L',IDDLD)
      CALL JEVECH('PVARIMR','L',IVARIM)
      CALL JEVECH('PINSTMR','L',IINSTM)
      CALL JEVECH('PINSTPR','L',IINSTP)
      CALL JEVECH('PCONTMR','L',ICONTM)

C RECUPERATION DU NOMBRE DE VARIABLES INTERNES PAR POINTS DE GAUSS
      CALL TECACH('OON','PVARIMR',7,JTAB,IRET)
      LGPG1 = MAX(JTAB(6),1)*JTAB(7)
      LGPG = LGPG1

C DONNEES EN SORTIE
      IF (RIGI) THEN
        CALL JEVECH('PMATUNS','E',IMATR)
      ENDIF

      IF (RESI) THEN
        CALL JEVECH('PVARIPR','E',IVARIP)
        CALL JEVECH('PCONTPR','E',ICONTP)
        CALL JEVECH('PVECTUR','E',IVECT)
      ELSE
        IVARIP=1
        ICONTP=1
        IVECT=1
      ENDIF

C CALCUL DES CONTRAINTES, VIP, FORCES INTERNES ET MATR TANG ELEMENTAIRES
      CALL NMFIHM(NDIM,NDDL,NNO1,NNO2,NPG,LGPG,IW,ZR(IW),
     &            ZR(IVF1),ZR(IVF2),IDF2,ZR(IDF2),ZI(IMATER),OPTION,
     &            ZR(IGEOM),ZR(IDDLM),ZR(IDDLD),IU,IP,
     &            ZR(ICONTM),ZR(ICONTP),ZR(IVECT),ZR(IMATR),
     &            ZR(IVARIM),ZR(IVARIP),ZR(IINSTM),ZR(IINSTP),
     &            ZR(ICARCR),ZK16(ICOMP),TYPMOD)

      END
