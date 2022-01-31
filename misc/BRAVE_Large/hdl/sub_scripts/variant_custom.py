import project_files
import project_parameters
import pads_NG_MEDIUM
import pads_NG_LARGE
import pads_NG_ULTRA

class variant_custom():

	def __init__(self,variant,sources_files_directory):
		self.variant = variant
		self.sources_files_directory = sources_files_directory

	def is_embedded(self):
		if (self.variant == 'NG-MEDIUM' or self.variant == 'NG-LARGE' or self.variant == 'NG-ULTRA'):
			return False
		else:
			return True

	def bank(self,option=None):
		if self.variant == 'NG-MEDIUM':
			import pads_NG_MEDIUM
			return pads_NG_MEDIUM.bank(option)
		elif self.variant == 'NG-LARGE':
			import pads_NG_LARGE
			return pads_NG_LARGE.bank(option)
		elif self.variant == 'NG-ULTRA':
			import pads_NG_ULTRA
			return pads_NG_ULTRA.bank(option)
						
	def pads(self,option=None):
		if self.variant == 'NG-MEDIUM':
			import pads_NG_MEDIUM
			return pads_NG_MEDIUM.pads(option)
		elif self.variant == 'NG-LARGE':
			import pads_NG_LARGE
			return pads_NG_LARGE.pads(option)
		elif self.variant == 'NG-ULTRA':
			import pads_NG_ULTRA
			return pads_NG_ULTRA.pads(option)
									
	def add_files(self,p,option=None):
		if self.variant == 'NG-MEDIUM' or self.variant == 'NG-MEDIUM-EMBEDDED':
			project_files.NG_MEDIUM_files(p,self.sources_files_directory,option)
		elif self.variant == 'NG-LARGE' or self.variant == 'NG-LARGE-EMBEDDED':
			project_files.NG_LARGE_files(p,self.sources_files_directory,option)
		elif self.variant == 'NG-ULTRA' or self.variant == 'NG-ULTRA-EMBEDDED':
			project_files.NG_ULTRA_files(p,self.sources_files_directory,option)
	
	def set_parameters(self,p,option=None):
		project_parameters.commun_parameters(p,option)
		if self.variant == 'NG-MEDIUM' or self.variant == 'NG-MEDIUM-EMBEDDED':
			project_parameters.NG_MEDIUM_parameters(p,option)
		elif self.variant == 'NG-LARGE' or self.variant == 'NG-LARGE-EMBEDDED':
			project_parameters.NG_LARGE_parameters(p,option)
		elif self.variant == 'NG-ULTRA' or self.variant == 'NG-ULTRA-EMBEDDED':
			project_parameters.NG_ULTRA_parameters(p,option)
				
	def set_options(self,p,option=None):
		project_parameters.commun_options(p,option)
		if self.variant == 'NG-MEDIUM' or self.variant == 'NG-MEDIUM-EMBEDDED':
			project_parameters.NG_MEDIUM_options(p,option)
		elif self.variant == 'NG-LARGE' or self.variant == 'NG-LARGE-EMBEDDED':
			project_parameters.NG_LARGE_options(p,option)
		elif self.variant == 'NG-ULTRA' or self.variant == 'NG-ULTRA-EMBEDDED':
			project_parameters.NG_ULTRA_options(p,option)
