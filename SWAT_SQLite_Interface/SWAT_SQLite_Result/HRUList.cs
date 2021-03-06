﻿using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace SWAT_SQLite_Result
{
    //public delegate void SwitchFromSubbasin2HRUEventHandler(ArcSWAT.HRU hru);

    public partial class HRUList : UserControl
    {
        public HRUList()
        {
            InitializeComponent();

            bGoHRU.Click += (s, e) => { makeChangeHappen(); };
        }

        public event SwitchFromSubbasin2HRUEventHandler onSwitch2HRU = null;

        private ArcSWAT.Subbasin _subbasin = null;

        public ArcSWAT.HRU HRU
        {
            get
            {
                if (cmbHRUs.Items.Count == 0 || cmbHRUs.SelectedIndex < 0) return null;

                int hruid = int.Parse(cmbHRUs.SelectedItem.ToString().Split(':')[0]);
                return _subbasin.HRUs[hruid];
            }
        }

        private void makeChangeHappen() { if (onSwitch2HRU != null) onSwitch2HRU(HRU); }

        private bool _isChangeWhenSelect = false;

        /// <summary>
        /// Would the change in selection become active immediately after selection changed.
        /// Usually true for HRU and false for subbasin
        /// </summary>
        public bool IsChangeWhenSelect
        {
            set
            {
                if (_isChangeWhenSelect)
                    cmbHRUs.SelectedIndexChanged -= (s, e) => { makeChangeHappen(); };
                _isChangeWhenSelect = value;

                if (_isChangeWhenSelect)
                    cmbHRUs.SelectedIndexChanged += (s, e) => { makeChangeHappen(); };            

            }
        }

        public ArcSWAT.Subbasin Subbasin
        {
            set
            {
                //get hrus
                cmbHRUs.Items.Clear();
                _subbasin = value;
                if (value == null || value.HRUs.Count == 0) return;
                
                foreach (ArcSWAT.HRU hru in value.HRUs.Values)
                    cmbHRUs.Items.Add(string.Format("{0}:{1:P2}", hru.ID, hru.AreaFractionSub));
                cmbHRUs.SelectedIndex = 0;
            }
        }
    }
}
