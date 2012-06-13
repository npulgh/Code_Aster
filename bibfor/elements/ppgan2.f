      SUBROUTINE PPGAN2(JGANO,NBSP,NCMP,VPG,VNO)
      IMPLICIT   NONE
      INCLUDE 'jeveux.h'
      INTEGER JGANO,NBSP,NCMP
      REAL*8 VNO(*),VPG(*)
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 13/06/2012   AUTEUR COURTOIS M.COURTOIS 
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
C RESPONSABLE PELLET J.PELLET
C
C     PASSAGE DES VALEURS POINTS DE GAUSS -> VALEURS AUX NOEUDS
C     POUR LES TYPE_ELEM AYANT 1 ELREFA
C ----------------------------------------------------------------------
C     IN     JGANO  ADRESSE DANS ZR DE LA MATRICE DE PASSAGE
C            NBSP   NOMBRE DE SOUS-POINTS
C            NCMP   NOMBRE DE COMPOSANTES
C            VPG    VECTEUR DES VALEURS AUX POINTS DE GAUSS
C     OUT    VNO    VECTEUR DES VALEURS AUX NOEUDS
C----------------------------------------------------------------------
      INTEGER INO,ISP,IPG,ICMP,NNO,NNO2,IADZI,IAZK24,NPG,JMAT,IMA,IATYMA
      INTEGER VALI(2)
      REAL*8 S
      CHARACTER*8 MA, TYPEMA
      CHARACTER*24 VALK(2)

C DEB ------------------------------------------------------------------

      NNO = NINT(ZR(JGANO-1+1))
      NPG = NINT(ZR(JGANO-1+2))
      CALL ASSERT(NNO*NPG.GT.0)

      CALL TECAEL(IADZI,IAZK24)
      NNO2 = ZI(IADZI+1)
      IF ( NNO2 .LT. NNO ) THEN
C       -- POUR CERTAINS ELEMENTS XFEM, IL EST NORMAL QUE NNO < NNO2 :
C          CE SONT DES ELEMENTS QUADRATIQUES QUI SE FONT PASSER POUR DES
C          ELEMENTS LINEAIRES
        IMA = ZI(IADZI)
        MA  = ZK24(IAZK24)(1:8)
        CALL JEVEUO(MA//'.TYPMAIL','L',IATYMA)
        CALL JENUNO(JEXNUM('&CATA.TM.NOMTM',ZI(IATYMA-1+IMA)),TYPEMA)
        VALK (1) = ZK24(IAZK24-1+3)(1:8)
        VALK (2) = TYPEMA
        VALI (1) = NNO2
        VALI (2) = NNO
        CALL U2MESG('F', 'ELEMENTS4_90',2,VALK,2,VALI,0,0.D0)
      ENDIF

C --- PASSAGE DES POINTS DE GAUSS AUX NOEUDS SOMMETS PAR MATRICE
C     V(NOEUD) = P * V(GAUSS)

      JMAT = JGANO + 2
      DO 40 ICMP = 1,NCMP
        DO 30 INO = 1,NNO
          DO 20 ISP = 1,NBSP
            S = 0.D0
            DO 10 IPG = 1,NPG
              S = S + ZR(JMAT-1+(INO-1)*NPG+IPG) *
     &                      VPG((IPG-1)*NCMP*NBSP+(ISP-1)*NCMP+ICMP)
   10       CONTINUE
            VNO((INO-1)*NCMP*NBSP+(ISP-1)*NCMP+ICMP) = S
   20     CONTINUE
   30   CONTINUE
   40 CONTINUE

      END
