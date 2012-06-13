      SUBROUTINE CAIMPD ( CHAR, LIGRMO, NOMA, FONREE )
      IMPLICIT   NONE
      INCLUDE 'jeveux.h'
      CHARACTER*4       FONREE
      CHARACTER*8       CHAR, NOMA
      CHARACTER*(*)     LIGRMO
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 13/06/2012   AUTEUR COURTOIS M.COURTOIS 
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
C
C BUT : STOCKAGE DE L'IMPEDANCE DANS UNE CARTE ALLOUEE SUR LE
C       LIGREL DU MODELE
C
C ARGUMENTS D'ENTREE:
C      CHAR   : NOM UTILISATEUR DU RESULTAT DE CHARGE
C      LIGRMO : NOM DU LIGREL DE MODELE
C      NOMA   : NOM DU MAILLAGE
C      FONREE : FONC OU REEL
C ----------------------------------------------------------------------
      INTEGER       IOCC, N, NIMPE, JVALV, JNCMP, NBMA, JMA
      CHARACTER*8   K8B, TYPMCL(2)
      CHARACTER*16  MOTCLF, MOTCLE(2)
      CHARACTER*19  CARTE
      CHARACTER*24  MESMAI
      INTEGER      IARG
C     ------------------------------------------------------------------
C
      CALL JEMARQ()
C
      MOTCLF = 'IMPE_FACE'
      CALL GETFAC ( MOTCLF , NIMPE )
C
      CARTE = CHAR//'.CHME.IMPE'
C
      IF (FONREE.EQ.'REEL') THEN
         CALL ALCART ( 'G', CARTE, NOMA, 'IMPE_R')
      ELSE IF (FONREE.EQ.'FONC') THEN
         CALL ALCART ( 'G', CARTE, NOMA, 'IMPE_F')
      ELSE
         CALL U2MESK('F','MODELISA2_37',1,FONREE)
      ENDIF
C
      CALL JEVEUO ( CARTE//'.NCMP', 'E', JNCMP )
      CALL JEVEUO ( CARTE//'.VALV', 'E', JVALV )
C
C --- STOCKAGE DES PRESSIONS  NULLES SUR TOUT LE MAILLAGE
C
      ZK8(JNCMP) = 'IMPE'
      IF (FONREE.EQ.'REEL') THEN
         ZR(JVALV) = 0.D0
      ELSE
         ZK8(JVALV) = '&FOZERO'
      ENDIF
      CALL NOCART ( CARTE, 1, ' ', 'NOM', 0,' ', 0, LIGRMO, 1 )
C
      MESMAI = '&&CAIMPD.MES_MAILLES'
      MOTCLE(1) = 'GROUP_MA'
      MOTCLE(2) = 'MAILLE'
      TYPMCL(1) = 'GROUP_MA'
      TYPMCL(2) = 'MAILLE'
C
C --- STOCKAGE DANS LA CARTE
C
      DO 10 IOCC = 1, NIMPE
C
         IF (FONREE.EQ.'REEL') THEN
            CALL GETVR8 ( MOTCLF, 'IMPE', IOCC,IARG,1, ZR(JVALV), N )
         ELSE
            CALL GETVID ( MOTCLF, 'IMPE', IOCC,IARG,1, ZK8(JVALV), N )
         ENDIF
C
         CALL RELIEM(LIGRMO, NOMA, 'NU_MAILLE', MOTCLF, IOCC, 2,
     &                                  MOTCLE, TYPMCL, MESMAI, NBMA )
         IF (NBMA.EQ.0) GOTO 10
         CALL JEVEUO ( MESMAI, 'L', JMA )
         CALL NOCART ( CARTE,3,K8B,'NUM',NBMA,K8B,ZI(JMA),' ',1)
         CALL JEDETR ( MESMAI )
C
 10   CONTINUE
C
      CALL JEDEMA()
      END
