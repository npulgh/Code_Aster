      SUBROUTINE CONVNU(NUMIN,NUMOUT,NOMVEC,BASE,NEQOUT)
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
C***********************************************************************
C    P. RICHARD     DATE 25/01/92
C-----------------------------------------------------------------------
C  BUT:  <  CONVECRSION DE NUMEROTATION >
C    CREER UN VECTEUR PERMETTANT DE PASSER D'UNE NUMEROTATION
C  A UNE AUTRE, CE VECTEUR DONNE POUR CHAQUEEQUATION DE LA NUMEROTATION
C  RESULTAT LE RANG DE L'EQUTION CORRESPONDANTE DANS LA NUMEROTATION
C   DE DEPART
      IMPLICIT REAL*8 (A-H,O-Z)
C
C   SEULS LES DDL PHYSIQUES SONT RESTITUE, DONC SLES LAGRANGES SONT
C   AUTOMATIQUEMENT MIS A ZERO
C
C  CETTE ROUTINE ENVOIE UN MESSAGE D'ALARME SI IL APPARAIT UNE PERTE
C  AU NIVEAU DES DDL PHYSIQUE
C  CE QUI REVIENT A DIRE QUE LA DIFFERENCE DOIT RESIDER
C   DANS LES LAGRANGES
C-----------------------------------------------------------------------
C
C NUMIN    /I/: NOM UT DE LA NUMEROTATION DE DEPART
C NUMOUT   /I/: NOM UT DE LA NUMEROTATION FINALE
C NOMVEC   /I/: NOM K24 DU VECTEUR D'ENTIER RESULTAT
C BASE     /I/: TYPE DE LA BASE JEVEUX 'G' OU 'V'
C NEQOUT   /O/: NOMBRE D'EQUATION DE LA NUMEROTATION RESULTAT
C
C
C
C
      INCLUDE 'jeveux.h'
      CHARACTER*1 BASE
      CHARACTER*8 MAIIN,MAIOUT
      CHARACTER*8 K8BID
      CHARACTER*19 NUMIN,NUMOUT
      CHARACTER*24 NOMVEC
      CHARACTER*24 VALK(4)
      LOGICAL ERREUR
C
      INTEGER IBID
      INTEGER VALI(2)
C
C-----------------------------------------------------------------------
      DATA IBID/0/
C-----------------------------------------------------------------------
C
C
C
C--------RECUPERATION DES MAILLAGE ET VERIFICATION COMPATIBILITE--------
C
      CALL JEMARQ()
      ERREUR = .FALSE.
      CALL DISMOI('F','NOM_MAILLA',NUMIN,'NUME_DDL',NBID,MAIIN,IRET)
      CALL DISMOI('F','NOM_MAILLA',NUMOUT,'NUME_DDL',NBID,MAIOUT,IRET)
C
      IF (MAIIN.NE.MAIOUT) THEN
        VALK (1) = NUMIN
        VALK (2) = MAIIN
        VALK (3) = NUMOUT
        VALK (4) = MAIOUT
        CALL U2MESG('F', 'ALGORITH12_62',4,VALK,0,0,0,0.D0)
      ENDIF
C
C
C------------RECUPERATION DES DIMENSIONS DES NUMEROTATIONS--------------
C
      CALL DISMOI('F','NB_EQUA',NUMIN,'NUME_DDL',NEQIN,K8BID,IBID)
      CALL DISMOI('F','NB_EQUA',NUMOUT,'NUME_DDL',NEQOUT,K8BID,IBID)
C
C-------------------ALLOCATION DU VECTEUR RESULTAT----------------------
C
      CALL WKVECT(NOMVEC,BASE//' V I',NEQOUT,LDCVN)
C
C
C-----------REQUETTE DES DEEQ DES NUMEROTATIONS-------------------------
C
      CALL JEVEUO(NUMIN//'.DEEQ','L',LLDEIN)
      CALL JEVEUO(NUMOUT//'.DEEQ','L',LLDEOU)
C
C
C------------------BOUCLE SUR LES DDL-----------------------------------
C
      DO 10 I=1,NEQOUT
        NUNO=ZI(LLDEOU+2*(I-1))
        ITYP=ZI(LLDEOU+2*(I-1)+1)
        IF(ITYP.GT.0) THEN
          CALL CHEDDL(ZI(LLDEIN),NEQIN,NUNO,ITYP,IRAN,1)
          IF(IRAN.EQ.0) THEN
             ERREUR=.TRUE.
        VALI (1) = NUNO
        VALI (2) = ITYP
             CALL U2MESG('A', 'ALGORITH12_63',0,' ',2,VALI,0,0.D0)
          ELSE
            ZI(LDCVN+I-1)=IRAN
          ENDIF
        ENDIF
C
 10   CONTINUE
C
C--------------------------TRAITEMENT ERREUR EVENTUELLE----------------
C
      IF(ERREUR) THEN
        CALL U2MESG('F', 'ALGORITH12_64',0,' ',0,0,0,0.D0)
      ENDIF
C
C------------------------LIBERATION DES OBJETS -------------------------
C
C
      CALL JEDEMA()
      END
