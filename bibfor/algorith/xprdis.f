      SUBROUTINE XPRDIS(FISREF,FISDIS,DIST,TOL,LCMIN)

      IMPLICIT NONE
      INCLUDE 'jeveux.h'
      CHARACTER*8  FISREF,FISDIS
      REAL*8       DIST,TOL,LCMIN

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
C   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C RESPONSABLE GENIAUT S.GENIAUT

C     ------------------------------------------------------------------
C
C       XPRDIS   : X-FEM PROPAGATION : DISTANCE MAXIMALE ENTRE DEUX
C       ------     -     --            ---
C                  FONDS DE FISSURE
C
C    DISTANCE MAXIMALE ENTRE DEUX FONDS DE FISSURE EN 3D. ON CALCULE
C    LA DISTANCE ENTRE CHAQUE POINT DU FOND DE LA FISSURE FISDIS ET LE
C    FOND DE LA FISSURE FISREF. EN SORTIE, ON DONNE LA VALEUR MAXIMALE
C    CALCULEE.
C
C    ENTREE
C        FISREF : FISSURE DE REFERENCE
C                 (NOM DU CONCEPT FISSURE X-FEM)
C        FISDIS : FISSURE POUR LAQUELLE ON CALCULE LA DISTANCE MAXIMALE
C                 (NOM DU CONCEPT FISSURE X-FEM)
C        DIST   : DISTANCE ATTENDUE
C        TOL    : TOLERANCE SUR LA DISTANCE CALCULEE
C        LCMIN  : LONGUEUR DE LA PLUS PETITE ARETE DU MAILLAGE
C
C    AUCUNE SORTIE
C
C     ------------------------------------------------------------------


      INTEGER        IFM,NIV,JFONR,NBPTFR,JFMULT,NUMFON,JFOND,
     &               NBPTFD,I,J,FON,IB
      CHARACTER*1    K1B
      REAL*8         EPS,XM,YM,ZM,XI1,YI1,ZI1,XJ1,YJ1,ZJ1,XIJ,YIJ,ZIJ,
     &               XIM,YIM,ZIM,S,NORM2,R8MAEM,R8PREM,XN,YN,ZN,D,DMIN
      REAL*8         DISMIN,DISMAX,DIFMIN,DIFMAX

C-----------------------------------------------------------------------
C     DEBUT
C-----------------------------------------------------------------------
      CALL JEMARQ()
      CALL INFMAJ()
      CALL INFNIV(IFM,NIV)

C     ---- FISREF ----

C     RETREIVE THE CRACK FRONT (FISREF)
      CALL JEVEUO(FISREF//'.FONDFISS','L',JFONR)
      CALL DISMOI('F','NB_POINT_FOND',FISREF,'FISS_XFEM',NBPTFR,K1B,IB)

C     RETRIEVE THE DIFFERENT PIECES OF THE CRACK FRONT
      CALL JEVEUO(FISREF//'.FONDMULT','L',JFMULT)
      CALL DISMOI('F','NB_FOND',FISREF,'FISS_XFEM',NUMFON,K1B,IB)

C     ---- FISDIS ----

C     RETREIVE THE CRACK FRONT (FISDIF)
      CALL JEVEUO(FISDIS//'.FONDFISS','L',JFOND)
      CALL DISMOI('F','NB_POINT_FOND',FISDIS,'FISS_XFEM',NBPTFD,K1B,IB)

C     ***************************************************************
C     EVALUATE THE PROJECTION OF EACH POINT OF FISDIF ON THE CRACK
C     FRONT FISREF
C     ***************************************************************

      DISMIN=R8MAEM()
      DISMAX=0.D0

C     BOUCLE SUR LES NOEUDS M DU MAILLAGE POUR CALCULER PROJ
      EPS = 1.D-12
      DO 200 I=1,NBPTFD

C        COORDINATES OF THE POINT M OF THE FRONT FISDIS
         XM=ZR(JFOND-1+4*(I-1)+1)
         YM=ZR(JFOND-1+4*(I-1)+2)
         ZM=ZR(JFOND-1+4*(I-1)+3)

C        INITIALISATION
         DMIN = R8MAEM()

C        BOUCLE SUR PT DE FONFIS
         DO 210 J=1,NBPTFR

C           CHECK IF THE CURRENT SEGMENT ON THE FRONT IS OUTSIDE THE
C           MODEL (ONLY IF THERE ARE MORE THAN ONE PIECE FORMING THE
C           FRONT)
            DO 213 FON=1,NUMFON
               IF ((J.EQ.ZI(JFMULT-1+2*FON)).AND.(J.LT.NBPTFR)) GOTO 210
213         CONTINUE

C           COORD PT I, ET J
            XI1 = ZR(JFONR-1+4*(J-1)+1)
            YI1 = ZR(JFONR-1+4*(J-1)+2)
            ZI1 = ZR(JFONR-1+4*(J-1)+3)
            IF(J.LT.NBPTFR) THEN
               XJ1 = ZR(JFONR-1+4*(J-1+1)+1)
               YJ1 = ZR(JFONR-1+4*(J-1+1)+2)
               ZJ1 = ZR(JFONR-1+4*(J-1+1)+3)
            ELSE
C              THIS IS ESSENTIAL FOR A CLOSED CRACK FRONT! IF THE LAST
C              POINT OF THE FRONT IS NOT CONNECTED TO THE FIRST ONE,
C              THE CRACK FRONT IS OPEN AND WRONG DISTANCES ARE
C              CALCULATED!
               XJ1 = ZR(JFONR-1+4*(1-1)+1)
               YJ1 = ZR(JFONR-1+4*(1-1)+2)
               ZJ1 = ZR(JFONR-1+4*(1-1)+3)
            ENDIF
C           VECTEUR IJ ET IM
            XIJ = XJ1-XI1
            YIJ = YJ1-YI1
            ZIJ = ZJ1-ZI1
            XIM = XM-XI1
            YIM = YM-YI1
            ZIM = ZM-ZI1

C           PARAM S (PRODUIT SCALAIRE...)
            S   = XIJ*XIM + YIJ*YIM + ZIJ*ZIM
            NORM2 = XIJ*XIJ + YIJ*YIJ + ZIJ*ZIJ
            CALL ASSERT(NORM2.GT.R8PREM())
            S     = S/NORM2
C           SI N=P(M) SORT DU SEGMENT
            IF((S-1).GE.EPS) S = 1.D0
            IF(S.LE.EPS)     S = 0.D0

C           COORD DE N
            XN = S*XIJ+XI1
            YN = S*YIJ+YI1
            ZN = S*ZIJ+ZI1

C           DISTANCE MN
C           SAVE CPU TIME: THE SQUARE OF THE DISTANCE IS EVALUATED!
            D = (XN-XM)*(XN-XM)+(YN-YM)*(YN-YM)+(ZN-ZM)*(ZN-ZM)
            IF(D.LT.DMIN) DMIN=D

 210     CONTINUE

         IF (DMIN.GT.DISMAX) DISMAX=DMIN
         IF (DMIN.LT.DISMIN) DISMIN=DMIN

 200  CONTINUE

      DISMAX=SQRT(DISMAX)
      DISMIN=SQRT(DISMIN)

C     CHECK IF THE TOLERANCE ON THE CALCULATED DISTANCE IS RESPECTED
      CALL ASSERT(LCMIN.GT.R8PREM())
      DIFMIN = (DISMIN-DIST)/LCMIN*100
      DIFMAX = (DISMAX-DIST)/LCMIN*100

C     WRITE SOME INFORMATIONS
      WRITE(IFM,*)
      WRITE(IFM,*)'------------------------------------------------'
      WRITE(IFM,*)'TEST SUR LA FORME DU FOND DE FISSURE PAR RAPPORT'
      WRITE(IFM,*)'AU FOND INITIAL. LE NOUVEAU FOND DOIT ETRE'
      WRITE(IFM,*)'HOMOTHETIQUE AU FOND INITIAL.'
      WRITE(IFM,*)
      WRITE(IFM,*)'LONGUEUR DE LA PLUS PETITE ARETE DU MAILLAGE:',LCMIN
      WRITE(IFM,901) TOL
      WRITE(IFM,*)
      WRITE(IFM,*)'DISTANCE ATTENDUE ENTRE LES DEUX FONDS: ',DIST
      WRITE(IFM,*)'DISTANCE MINIMALE CALCULEE = ',DISMIN
      WRITE(IFM,900) DIFMIN
      WRITE(IFM,*)'DISTANCE MAXIMALE CALCULEE = ',DISMAX
      WRITE(IFM,900) DIFMAX
      WRITE(IFM,*)
      WRITE(IFM,*)'L''ERREUR EST CALCULE PAR RAPPORT A LA LONGUEUR DE'
      WRITE(IFM,*)'LA PLUS PETITE ARETE DU MAILLAGE.'
      WRITE(IFM,*)
      IF ((ABS(DIFMIN).LE.TOL).AND.(ABS(DIFMAX).LE.TOL)) THEN
C        OK. TEST PASSED.
         WRITE(IFM,*)'RESULTAT DU TEST: OK.'
         WRITE(IFM,*)'------------------------------------------------'
         WRITE(IFM,*)
      ELSE
C        TEST FAILED.
         CALL U2MESS('A','XFEM2_91')
      ENDIF

900   FORMAT('                     ERREUR = ',F6.1,'%')
901   FORMAT(' TOLERANCE = ',F6.1,'%')

C-----------------------------------------------------------------------
C     FIN
C-----------------------------------------------------------------------
      CALL JEDEMA()
      END
