      SUBROUTINE FETCPU(OPTION,TEMPS,INFOFE,RANG,IFM)
C-----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGELINE  DATE 04/04/2007   AUTEUR ABBAS M.ABBAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2005  EDF R&D                  WWW.CODE-ASTER.ORG
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
C-----------------------------------------------------------------------
C    - FONCTION REALISEE:  PROFILING ALGO FETI POUR SOULAGER ALFETI.F
C     ------------------------------------------------------------------
C     IN  OPTION : IN   : OPTION DE LA ROUTINE
C     IN  TEMPS  : R8   : VECTEUR DE TIMING POUR UTTCPU
C     IN  INFOFE : CH19 : CHAINE DE CHARACTERES POUR MONITORING FETI
C     IN  RANG   : IN   : RANG DU PROCESSEUR
C     IN  IFM    : IN   : UNITE LOGIQUE D'IMPRESSION STANDARD
C----------------------------------------------------------------------
C RESPONSABLE BOITEAU O.BOITEAU
C CORPS DU PROGRAMME
      IMPLICIT NONE

C DECLARATION PARAMETRES D'APPELS
      INTEGER      OPTION,RANG,IFM
      REAL*8       TEMPS(6)
      CHARACTER*24 INFOFE

      IF (INFOFE(9:9).EQ.'T') THEN
        IF (OPTION.EQ.1) THEN
          CALL UTTCPU(37,'INIT ',6,TEMPS)
          CALL UTTCPU(37,'DEBUT',6,TEMPS)
        ELSE IF (OPTION.EQ.2) THEN
          CALL UTTCPU(37,'FIN  ',6,TEMPS)
          WRITE(IFM,*)'PROC ',RANG,' INIT 1 CPU/SYS: ',TEMPS(5),TEMPS(6)
          CALL UTTCPU(38,'INIT ',6,TEMPS)
          CALL UTTCPU(38,'DEBUT',6,TEMPS)
        ELSE IF (OPTION.EQ.3) THEN
          CALL UTTCPU(38,'FIN  ',6,TEMPS)
          WRITE(IFM,*)'PROC ',RANG,' INIT 2 CPU/SYS: ',TEMPS(5),TEMPS(6)
          CALL UTTCPU(39,'INIT ',6,TEMPS)
          CALL UTTCPU(39,'DEBUT',6,TEMPS)
        ELSE IF (OPTION.EQ.31) THEN
          CALL UTTCPU(39,'INIT ',6,TEMPS)
          CALL UTTCPU(39,'DEBUT',6,TEMPS)
        ELSE IF (OPTION.EQ.4) THEN
          CALL UTTCPU(39,'FIN  ',6,TEMPS)
          WRITE(IFM,*)'PROC ',RANG,' INIT 3 CPU/SYS: ',TEMPS(5),TEMPS(6)
        ELSE IF (OPTION.EQ.5) THEN
          CALL UTTCPU(40,'INIT ',6,TEMPS)
          CALL UTTCPU(40,'DEBUT',6,TEMPS)
        ELSE IF (OPTION.EQ.6) THEN
          CALL UTTCPU(40,'FIN  ',6,TEMPS)
          WRITE(IFM,*)'PROC ',RANG,' FETFIV CPU/SYS: ',TEMPS(5),TEMPS(6)
          CALL UTTCPU(41,'INIT ',6,TEMPS)
          CALL UTTCPU(41,'DEBUT',6,TEMPS)
        ELSE IF (OPTION.EQ.7) THEN
          CALL UTTCPU(41,'FIN  ',6,TEMPS)
          WRITE(IFM,*)'PROC ',RANG,' DDOT/DAXPY/FETPRJ CPU/SYS: ',
     &      TEMPS(5),TEMPS(6)
          CALL UTTCPU(43,'INIT ',6,TEMPS)
          CALL UTTCPU(43,'DEBUT',6,TEMPS)
        ELSE IF (OPTION.EQ.9) THEN
            CALL UTTCPU(43,'FIN  ',6,TEMPS)
            WRITE(IFM,*)'PROC ',RANG,' TEST CV CPU/SYS: ',TEMPS(5),
     &        TEMPS(6)
        ELSE IF (OPTION.EQ.10) THEN
          CALL UTTCPU(44,'INIT ',6,TEMPS)
          CALL UTTCPU(44,'DEBUT',6,TEMPS)
        ELSE IF (OPTION.EQ.11) THEN
          CALL UTTCPU(44,'FIN  ',6,TEMPS)
          WRITE(IFM,*)'PROC ',RANG,' FETPRC+SCA+PRJ CPU/SYS: ',TEMPS(5),
     &                TEMPS(6)
          CALL UTTCPU(45,'INIT ',6,TEMPS)
          CALL UTTCPU(45,'DEBUT',6,TEMPS)
        ELSE IF (OPTION.EQ.12) THEN
          CALL UTTCPU(45,'FIN  ',6,TEMPS)
          WRITE(IFM,*)'PROC ',RANG,' FETREO CPU/SYS: ',TEMPS(5),TEMPS(6)
        ELSE
          CALL U2MESS('F','ALGELINE_40')
        ENDIF
      ENDIF
      END
