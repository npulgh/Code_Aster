      SUBROUTINE GABSCU(LOBJ2,COORN,NOMNO,FOND,XL,ABSGAM)
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
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
      IMPLICIT REAL*8 (A-H,O-Z)
C
C     ----------------------------------------------------------------
C FONCTION REALISEE:
C
C     POUR CHAQUE NOEUD DU FOND DE FISSURE GAMM0 ON CALCULE
C     SON ABSCISSE CURVILIGNE
C     TRAITEMENT PARTICULIER SI LA COURBE EST FERMEE
C
C     ------------------------------------------------------------------
C ENTREE:
C        LOBJ2  : NOMBRE DE NOEUD DE GAMM0
C        COORN  : NOM DE L'OBJET CONTENANT LES COORDONNEES DES NOEUDS
C        NOMNO  : NOM DE L'OBJET CONTENANT LES NOMS DES NOEUDS
C        FOND   : NOMS DES NOEUDS DU FOND DE FISSURE
C
C SORTIE:
C        XL     : LONGUEUR DE LA FISSURE
C        ABSGAM : ABSCISSE CURVILIGNE DES NOEUDS DU FOND DE FISSURE
C     ------------------------------------------------------------------
C
      INCLUDE 'jeveux.h'
      CHARACTER*24      NOMNO,COORN,NUMGAM,ABSGAM,FOND
C
      INTEGER           LOBJ2,IADRCO,IADRNO,IADNUM,IADABS
C
      REAL*8            XI1,YI1,ZI1,XJ1,YJ1,ZJ1,XIJ,YIJ,ZIJ,XL
C

      CALL JEMARQ()
      CALL JEVEUO(COORN,'L',IADRCO)
      CALL JEVEUO(FOND, 'L',IADRNO)
C
C CALCUL DE LA LONGUEUR DU FOND DE FISSURE
C
C RECUPERATION DES NUMEROS DE NOEUDS DE GAMM0
C
C
      NUMGAM = '&&LEGEND.NUMGAMM0'
      CALL WKVECT(NUMGAM,'V V I',LOBJ2,IADNUM)
      DO 2 J=1,LOBJ2
            CALL JENONU(JEXNOM(NOMNO,ZK8(IADRNO+J-1)),ZI(IADNUM+J-1))
2     CONTINUE
C
      XL = 0.D0
      DO 3 J=1,LOBJ2-1
        XI1 = ZR(IADRCO+(ZI(IADNUM+J-1)  -1)*3+1-1)
        YI1 = ZR(IADRCO+(ZI(IADNUM+J-1)  -1)*3+2-1)
        ZI1 = ZR(IADRCO+(ZI(IADNUM+J-1)  -1)*3+3-1)
        XJ1 = ZR(IADRCO+(ZI(IADNUM+J+1-1)-1)*3+1-1)
        YJ1 = ZR(IADRCO+(ZI(IADNUM+J+1-1)-1)*3+2-1)
        ZJ1 = ZR(IADRCO+(ZI(IADNUM+J+1-1)-1)*3+3-1)
        XIJ = XJ1-XI1
        YIJ = YJ1-YI1
        ZIJ = ZJ1-ZI1
        XL = XL + SQRT(XIJ*XIJ + YIJ *YIJ +ZIJ*ZIJ)
3     CONTINUE
C
C  CALCUL DE L'ABSCISSE CURVILIGNE DE CHAQUE NOEUD DE GAMM0
C
      ABSGAM = '&&LEGEND.ABSGAMM0'
      CALL JEEXIN(ABSGAM,IRET)
      IF (IRET.EQ.0) THEN
        CALL WKVECT(ABSGAM,'V V R',LOBJ2,IADABS)
C
        ZR(IADABS) = 0.D0
        DO 4 I=1,LOBJ2-1
          XI1 = ZR(IADRCO+(ZI(IADNUM+I-1)  -1)*3+1-1)
          YI1 = ZR(IADRCO+(ZI(IADNUM+I-1)  -1)*3+2-1)
          ZI1 = ZR(IADRCO+(ZI(IADNUM+I-1)  -1)*3+3-1)
          XJ1 = ZR(IADRCO+(ZI(IADNUM+I+1-1)-1)*3+1-1)
          YJ1 = ZR(IADRCO+(ZI(IADNUM+I+1-1)-1)*3+2-1)
          ZJ1 = ZR(IADRCO+(ZI(IADNUM+I+1-1)-1)*3+3-1)
          XIJ = XJ1-XI1
          YIJ = YJ1-YI1
          ZIJ = ZJ1-ZI1
          ZR(IADABS+I+1-1) = ZR(IADABS+I-1)+
     &                     SQRT(XIJ*XIJ + YIJ *YIJ + ZIJ*ZIJ)
  4     CONTINUE
      ENDIF
C
C DESTRUCTION DES OBJETS DE TRAVAIL
C
      CALL JEDETR (NUMGAM)
C
      CALL JEDEMA()
      END
