      SUBROUTINE OP9999()
      IMPLICIT NONE
C     ------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF SUPERVIS  DATE 13/06/2012   AUTEUR COURTOIS M.COURTOIS 
C RESPONSABLE LEFEBVRE J-P.LEFEBVRE
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
C     OPERATEUR DE CLOTURE
C     ------------------------------------------------------------------
C     FIN OP9999
C     ------------------------------------------------------------------
      INCLUDE 'jeveux.h'
      INTEGER      IUNIFI, ICHK , INFO, NBENRE, NBOCT
      INTEGER      IFM, IUNERR, IUNRES, IUNMES
      INTEGER      I, L, ICMD, JCO, NBCO, NBEXT, NFHDF
      LOGICAL      ULEXIS
      CHARACTER*8  K8B, OUINON
      CHARACTER*16 FCHIER, FHDF, TYPRES
      CHARACTER*80 FICH
      INTEGER      IARG
C     ------------------------------------------------------------------
C
      CALL JEMARQ()
      INFO = 1

C     LIBERE TOUS LES COMPOSANTS CHARGES DYNAMIQUEMENT
      CALL DLLCLS()

C     TEST ERREUR E SANS ERREUR F
      CALL CHKMSG(1, ICHK)

C     -----  FIN DE LA ZONE DE TEST ------------------------------------
C
      IFM    = 0
      FCHIER = ' '
      CALL GETVIS ( ' ', 'UNITE'  , 1,IARG,1, IFM   , L )
      IF ( .NOT. ULEXIS( IFM ) ) THEN
         CALL ULOPEN ( IFM, ' ', FCHIER, 'NEW', 'O' )
      ENDIF
C
      TYPRES = 'RESULTAT_SDASTER'
      NBCO = 0
      CALL GETTYP(TYPRES, NBCO, K8B)
      IF (NBCO .GT. 0) THEN
        CALL WKVECT('&&OP9999.NOM', 'V V K8', NBCO, JCO)
        CALL GETTYP(TYPRES, NBCO, ZK8(JCO))
        DO 10 I = 1 , NBCO
           WRITE(IFM,1000)
           CALL RSINFO ( ZK8(JCO-1+I) , IFM )
 10     CONTINUE
      ENDIF
C
      IUNERR = IUNIFI('ERREUR')
      IUNMES = IUNIFI('MESSAGE')
      IUNRES = IUNIFI('RESULTAT')
C
C     --- SUPPRESSION DES CONCEPTS TEMPORAIRES DES MACRO
      CALL JEDETC('G','.',1)

C     -- IMPRESSION DE LA TAILLE DES CONCEPTS DE LA BASE GLOBALE:
      CALL UIMPBA('G',IUNMES)
C
C     --- RETASSAGE EVENTUEL DE LA GLOBALE
      CALL GETVTX(' ','RETASSAGE',1,IARG,1,OUINON,L)
      IF(OUINON .EQ. 'OUI') CALL JETASS('G')
C
C     --- SAUVEGARDE DE LA GLOBALE AU FORMAT HDF
      FHDF = 'NON'
      CALL GETVTX(' ','FORMAT_HDF',1,IARG,1,FHDF,NFHDF)
      IF (NFHDF .GT. 0) THEN
        IF ( FHDF .EQ. 'OUI' ) THEN
          IF(OUINON .EQ. 'OUI')THEN
            CALL U2MESS ('A','SUPERVIS2_8')
          ENDIF
          FICH = 'bhdf.1'
          CALL JEIMHD(FICH,'G')
        ENDIF
      ENDIF
C
C     RECUPERE LA POSITION D'UN ENREGISTREMENT SYSTEME CARACTERISTIQUE
      CALL JELIAD('G', NBENRE, NBOCT)
      CALL JDCSET('jeveux_sysaddr', NBOCT)
C
C     --- APPEL JXVERI POUR VERIFIER LA BONNE FIN D'EXECUTION
      CALL JXVERI(' ')
C
C     --- CLOTURE DES FICHIERS ---
      CALL JELIBF( 'SAUVE' , 'G' , INFO)
      IF (IUNERR.GT.0) WRITE(IUNERR,*)
     +        '<I> <FIN> FERMETURE DE LA BASE "GLOBALE" EFFECTUEE.'
      IF (IUNRES.GT.0) WRITE(IUNRES,*)
     +        '<I> <FIN> FERMETURE DE LA BASE "GLOBALE" EFFECTUEE.'

      CALL JELIBF( 'DETRUIT' , 'V' , INFO)
C
C     --- RETASSAGE EFFECTIF ----
      IF(OUINON .EQ. 'OUI') THEN
         CALL JXCOPY('G','GLOBALE','V','VOLATILE',NBEXT)
         IF (IUNERR.GT.0) WRITE(IUNERR,'(A,I2,A)')
     +   ' <I> <FIN> RETASSAGE DE LA BASE "GLOBALE" EFFECTUEE,', NBEXT,
     +   ' FICHIER(S) UTILISE(S).'
         IF (IUNRES.GT.0) WRITE(IUNRES,'(A,I2,A)')
     +   ' <I> <FIN> RETASSAGE DE LA BASE "GLOBALE" EFFECTUEE,', NBEXT,
     +   ' FICHIER(S) UTILISE(S).'
      ENDIF
C
C     --- IMPRESSION DES STATISTIQUES ( AVANT CLOTURE DE JEVEUX ) ---
      CALL U2MESS('I', 'SUPERVIS2_97')
      IF (IUNERR.GT.0) WRITE(IUNERR,*)
     +     '<I> <FIN> ARRET NORMAL DANS "FIN" PAR APPEL A "JEFINI".'
      IF (IUNRES.GT.0) WRITE(IUNRES,*)
     +     '<I> <FIN> ARRET NORMAL DANS "FIN" PAR APPEL A "JEFINI".'
C
C     --- LA CLOTURE DE JEVEUX ---
C
      CALL JEFINI ( 'NORMAL' )
C
 1000 FORMAT(/,1X,'======>')
C
      CALL JEDEMA()
      END
